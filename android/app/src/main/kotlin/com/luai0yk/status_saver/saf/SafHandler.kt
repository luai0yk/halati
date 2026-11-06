package com.luai0yk.status_saver.saf

import android.app.Activity
import android.content.Context
import android.content.ContentResolver
import android.content.ContentValues
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.os.storage.StorageManager
import android.provider.DocumentsContract
import android.provider.MediaStore
import android.util.Size
import androidx.documentfile.provider.DocumentFile
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileOutputStream
import java.io.InputStream
import java.security.MessageDigest

class SafHandler(
    private val activity: Activity,
    private val channel: MethodChannel
) : MethodChannel.MethodCallHandler {

    companion object {
        const val REQUEST_CODE_SAF_TREE = 4210
        const val REQUEST_CODE_SAF_SAVE_FOLDER = 4211
        private const val WHATSAPP_PACKAGE = "com.whatsapp"
        private const val WHATSAPP_BUSINESS_PACKAGE = "com.whatsapp.w4b"
        private const val STATUSES_FOLDER = ".Statuses"
    }

    private var pendingResult: MethodChannel.Result? = null

    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "checkDirectoryAccess" -> {
                val uriString = call.argument<String>("uri")
                checkDirectoryAccess(uriString, result)
            }
            "checkSaveFolderAccess" -> {
                val uriString = call.argument<String>("uri")
                checkSaveFolderAccess(uriString, result)
            }
            "requestDirectorySelection" -> {
                val initialUriHint = call.argument<String>("initialUriHint")
                val isBusiness = call.argument<Boolean>("isBusiness") ?: false
                requestDirectorySelection(initialUriHint, isBusiness, result)
            }
            "requestCustomSaveFolder" -> {
                val initialUriHint = call.argument<String>("initialUriHint")
                requestCustomSaveFolder(initialUriHint, result)
            }
            "releaseDirectoryAccess" -> {
                val uriString = call.argument<String>("uri")
                releaseDirectoryAccess(uriString, result)
            }
            "discoverStatuses" -> {
                val treeUri = call.argument<String>("treeUri")
                if (treeUri.isNullOrEmpty()) {
                    result.error("INVALID_ARGUMENT", "treeUri is required", null)
                    return
                }
                discoverStatuses(treeUri, result)
            }
            "getThumbnail" -> {
                val documentUri = call.argument<String>("documentUri")
                val width = call.argument<Int>("width") ?: 300
                val height = call.argument<Int>("height") ?: 300
                if (documentUri.isNullOrEmpty()) {
                    result.error("INVALID_ARGUMENT", "documentUri is required", null)
                    return
                }
                getThumbnail(documentUri, width, height, result)
            }
            "getMediaMetadata" -> {
                val documentUri = call.argument<String>("documentUri")
                if (documentUri.isNullOrEmpty()) {
                    result.error("INVALID_ARGUMENT", "documentUri is required", null)
                    return
                }
                getMediaMetadata(documentUri, result)
            }
            "saveToMediaStore" -> {
                val documentUri = call.argument<String>("documentUri")
                val mediaType = call.argument<String>("mediaType") ?: "image"
                val fileName = call.argument<String>("fileName") ?: "status_${System.currentTimeMillis()}"
                val isBusiness = call.argument<Boolean>("isBusiness") ?: false
                val customTreeUri = call.argument<String>("customTreeUri")
                if (documentUri.isNullOrEmpty()) {
                    result.error("INVALID_ARGUMENT", "documentUri is required", null)
                    return
                }
                saveToMediaStore(documentUri, mediaType, fileName, isBusiness, customTreeUri, result)
            }
            "getFullMediaFile" -> {
                val documentUri = call.argument<String>("documentUri")
                val fileName = call.argument<String>("fileName") ?: "media_${System.currentTimeMillis()}"
                if (documentUri.isNullOrEmpty()) {
                    result.error("INVALID_ARGUMENT", "documentUri is required", null)
                    return
                }
                getFullMediaFile(documentUri, fileName, result)
            }
            "deleteFromMediaStore" -> {
                val mediaStoreUri = call.argument<String>("mediaStoreUri")
                if (mediaStoreUri.isNullOrEmpty()) {
                    result.error("INVALID_ARGUMENT", "mediaStoreUri is required", null)
                    return
                }
                deleteFromMediaStore(mediaStoreUri, result)
            }
            else -> result.notImplemented()
        }
    }

    private fun checkDirectoryAccess(uriString: String?, result: MethodChannel.Result) {
        if (uriString.isNullOrEmpty()) {
            result.success(mapOf("granted" to false, "accessible" to false))
            return
        }

        try {
            val targetUri = Uri.parse(uriString)
            var hasPermission = false
            for (permission in activity.contentResolver.persistedUriPermissions) {
                if (permission.uri == targetUri && permission.isReadPermission) {
                    hasPermission = true
                    break
                }
            }

            if (!hasPermission) {
                result.success(mapOf("granted" to false, "accessible" to false))
                return
            }

            // Check if directory exists and is readable
            val docFile = DocumentFile.fromTreeUri(activity, targetUri)
            val isAccessible = docFile != null && docFile.exists() && docFile.canRead()

            result.success(mapOf("granted" to true, "accessible" to isAccessible))
        } catch (e: Exception) {
            result.success(mapOf("granted" to false, "accessible" to false, "error" to (e.message ?: "Unknown error")))
        }
    }

    private fun checkSaveFolderAccess(uriString: String?, result: MethodChannel.Result) {
        if (uriString.isNullOrEmpty()) {
            result.success(mapOf("granted" to false, "accessible" to false))
            return
        }

        try {
            val targetUri = Uri.parse(uriString)
            var hasPermission = false
            for (permission in activity.contentResolver.persistedUriPermissions) {
                if (permission.uri == targetUri && permission.isReadPermission && permission.isWritePermission) {
                    hasPermission = true
                    break
                }
            }

            if (!hasPermission) {
                result.success(mapOf("granted" to false, "accessible" to false))
                return
            }

            val docFile = DocumentFile.fromTreeUri(activity, targetUri)
            val isAccessible = docFile != null && docFile.exists() && docFile.canWrite()
            val displayPath = if (isAccessible) getFriendlyPath(activity, targetUri) else ""

            result.success(mapOf("granted" to true, "accessible" to isAccessible, "displayPath" to displayPath))
        } catch (e: Exception) {
            result.success(mapOf("granted" to false, "accessible" to false, "error" to (e.message ?: "Unknown error")))
        }
    }

    private fun getFriendlyPath(context: Context, treeUri: Uri): String {
        try {
            val docId = DocumentsContract.getTreeDocumentId(treeUri)
            val parts = docId.split(":")
            if (parts.size > 1) {
                val relative = parts[1]
                if (parts[0].equals("primary", ignoreCase = true)) {
                    return relative.ifEmpty { "Internal Storage" }
                } else {
                    return "${parts[0]}/$relative"
                }
            }
        } catch (_: Exception) {}
        return DocumentFile.fromTreeUri(context, treeUri)?.name ?: (treeUri.lastPathSegment ?: "Custom Folder")
    }

    private fun requestCustomSaveFolder(initialUriHint: String?, result: MethodChannel.Result) {
        if (pendingResult != null) {
            result.error("ALREADY_ACTIVE", "A folder selection is already in progress", null)
            return
        }

        pendingResult = result

        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
            flags = Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                    Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION or
                    Intent.FLAG_GRANT_PREFIX_URI_PERMISSION
            putExtra("android.provider.extra.SHOW_ADVANCED", true)
            putExtra("android.content.extra.SHOW_ADVANCED", true)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && !initialUriHint.isNullOrEmpty()) {
            try {
                intent.putExtra(DocumentsContract.EXTRA_INITIAL_URI, Uri.parse(initialUriHint))
            } catch (_: Exception) {}
        }

        try {
            activity.startActivityForResult(intent, REQUEST_CODE_SAF_SAVE_FOLDER)
        } catch (e: Exception) {
            pendingResult = null
            result.error("ACTIVITY_NOT_FOUND", "Could not start folder picker: ${e.message}", null)
        }
    }

    private fun requestDirectorySelection(initialUriHint: String?, isBusiness: Boolean, result: MethodChannel.Result) {
        if (pendingResult != null) {
            result.error("ALREADY_ACTIVE", "A folder selection is already in progress", null)
            return
        }

        pendingResult = result

        val storageManager = activity.getSystemService(Context.STORAGE_SERVICE) as? StorageManager

        val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && storageManager != null) {
            try {
                storageManager.primaryStorageVolume.createOpenDocumentTreeIntent()
            } catch (_: Exception) {
                Intent(Intent.ACTION_OPEN_DOCUMENT_TREE)
            }
        } else {
            Intent(Intent.ACTION_OPEN_DOCUMENT_TREE)
        }.apply {
            flags = Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION or
                    Intent.FLAG_GRANT_PREFIX_URI_PERMISSION
            putExtra("android.provider.extra.SHOW_ADVANCED", true)
            putExtra("android.content.extra.SHOW_ADVANCED", true)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val hintUri: Uri? = if (!initialUriHint.isNullOrEmpty()) {
                Uri.parse(initialUriHint)
            } else {
                val pkg = if (isBusiness) WHATSAPP_BUSINESS_PACKAGE else WHATSAPP_PACKAGE
                val folder = if (isBusiness) "WhatsApp Business" else "WhatsApp"
                val legacyRawPath = "$folder%2FMedia%2F$STATUSES_FOLDER"
                val modernRawPath = "Android%2Fmedia%2F$pkg%2F$folder%2FMedia%2F$STATUSES_FOLDER"

                val isLegacy = try {
                    val legacyDir = File(Environment.getExternalStorageDirectory(), "$folder/Media/.Statuses")
                    legacyDir.exists()
                } catch (_: Exception) {
                    false
                }

                val targetRawPath = if (isLegacy) legacyRawPath else modernRawPath
                val treeAuthority = "com.android.externalstorage.documents"

                val existingUri = intent.getParcelableExtra<Uri>(DocumentsContract.EXTRA_INITIAL_URI)
                if (existingUri != null) {
                    val scheme = existingUri.toString().replace("/root/", "/document/") + "%3A$targetRawPath"
                    Uri.parse(scheme)
                } else {
                    if (isLegacy) {
                        Uri.parse("content://$treeAuthority/tree/primary%3A$folder%2FMedia/document/primary%3A$targetRawPath")
                    } else {
                        Uri.parse("content://$treeAuthority/tree/primary%3AAndroid%2Fmedia/document/primary%3A$targetRawPath")
                    }
                }
            }

            if (hintUri != null) {
                intent.putExtra(DocumentsContract.EXTRA_INITIAL_URI, hintUri)
            }
        }

        try {
            activity.startActivityForResult(intent, REQUEST_CODE_SAF_TREE)
        } catch (e: Exception) {
            pendingResult = null
            result.error("ACTIVITY_NOT_FOUND", "Could not start file picker: ${e.message}", null)
        }
    }

    fun handleActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != REQUEST_CODE_SAF_TREE && requestCode != REQUEST_CODE_SAF_SAVE_FOLDER) {
            return false
        }

        val callback = pendingResult ?: return false
        pendingResult = null

        if (resultCode != Activity.RESULT_OK || data == null || data.data == null) {
            callback.error("USER_CANCELLED", "User cancelled folder selection", null)
            return true
        }

        val treeUri = data.data!!

        if (requestCode == REQUEST_CODE_SAF_SAVE_FOLDER) {
            try {
                val takeFlags = Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                activity.contentResolver.takePersistableUriPermission(treeUri, takeFlags)

                val docFile = DocumentFile.fromTreeUri(activity, treeUri)
                if (docFile == null || !docFile.exists() || !docFile.canWrite()) {
                    callback.error("PERMISSION_ERROR", "The selected folder is not writable", null)
                    return true
                }

                // Auto-create media subdirectories
                docFile.findFile("Halati Videos") ?: docFile.createDirectory("Halati Videos")
                docFile.findFile("Halati Images") ?: docFile.createDirectory("Halati Images")
                docFile.findFile("Halati Audios") ?: docFile.createDirectory("Halati Audios")

                val displayPath = getFriendlyPath(activity, treeUri)
                callback.success(mapOf(
                    "uri" to treeUri.toString(),
                    "displayPath" to displayPath
                ))
            } catch (e: Exception) {
                callback.error("PERMISSION_ERROR", "Failed to access folder: ${e.message}", null)
            }
            return true
        }

        try {
            // Take persistable permission
            val takeFlags = Intent.FLAG_GRANT_READ_URI_PERMISSION
            activity.contentResolver.takePersistableUriPermission(treeUri, takeFlags)

            // Validate that the folder belongs to WhatsApp
            val path = treeUri.path ?: ""
            val isWhatsAppFolder = path.contains(WHATSAPP_PACKAGE, ignoreCase = true) ||
                    path.contains(WHATSAPP_BUSINESS_PACKAGE, ignoreCase = true) ||
                    path.contains(STATUSES_FOLDER, ignoreCase = true) ||
                    path.contains("WhatsApp", ignoreCase = true)

            if (!isWhatsAppFolder) {
                // Return URI anyway with warning or validation result, but flag it
                // To adhere to AGENT.md: confirm selection or allow user to proceed
            }

            callback.success(treeUri.toString())
        } catch (e: Exception) {
            callback.error("PERMISSION_ERROR", "Failed to take persistable URI permission: ${e.message}", null)
        }

        return true
    }

    private fun releaseDirectoryAccess(uriString: String?, result: MethodChannel.Result) {
        if (uriString.isNullOrEmpty()) {
            result.success(false)
            return
        }

        try {
            val uri = Uri.parse(uriString)
            activity.contentResolver.releasePersistableUriPermission(
                uri,
                Intent.FLAG_GRANT_READ_URI_PERMISSION
            )
            result.success(true)
        } catch (e: Exception) {
            result.error("RELEASE_ERROR", "Failed to release URI permission: ${e.message}", null)
        }
    }

    private fun discoverStatuses(treeUriString: String, result: MethodChannel.Result) {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val treeUri = Uri.parse(treeUriString)
                val treeDocId = DocumentsContract.getTreeDocumentId(treeUri)

                val projection = arrayOf(
                    DocumentsContract.Document.COLUMN_DOCUMENT_ID,
                    DocumentsContract.Document.COLUMN_DISPLAY_NAME,
                    DocumentsContract.Document.COLUMN_MIME_TYPE,
                    DocumentsContract.Document.COLUMN_SIZE,
                    DocumentsContract.Document.COLUMN_LAST_MODIFIED
                )

                val mediaList = mutableListOf<Map<String, Any>>()
                queryFolderDocuments(treeUri, treeDocId, projection, mediaList)

                // Sort newest first
                mediaList.sortByDescending { (it["lastModified"] as? Long) ?: 0L }

                withContext(Dispatchers.Main) {
                    result.success(mediaList)
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("DISCOVERY_FAILED", "Failed to discover statuses: ${e.message}", null)
                }
            }
        }
    }

    private fun queryFolderDocuments(
        treeUri: Uri,
        folderDocId: String,
        projection: Array<String>,
        mediaList: MutableList<Map<String, Any>>
    ) {
        try {
            val childrenUri = DocumentsContract.buildChildDocumentsUriUsingTree(treeUri, folderDocId)
            activity.contentResolver.query(childrenUri, projection, null, null, null)?.use { cursor ->
                val idCol = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_DOCUMENT_ID)
                val nameCol = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_DISPLAY_NAME)
                val mimeCol = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_MIME_TYPE)
                val sizeCol = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_SIZE)
                val dateCol = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_LAST_MODIFIED)

                while (cursor.moveToNext()) {
                    val docId = cursor.getString(idCol)
                    val name = cursor.getString(nameCol) ?: ""
                    val mimeType = cursor.getString(mimeCol) ?: ""
                    val size = if (cursor.isNull(sizeCol)) 0L else cursor.getLong(sizeCol)
                    val lastModified = if (cursor.isNull(dateCol)) 0L else cursor.getLong(dateCol)

                    // If it is a subfolder named .Statuses, traverse into it
                    if (mimeType == DocumentsContract.Document.MIME_TYPE_DIR) {
                        if (name.equals(STATUSES_FOLDER, ignoreCase = true) || docId.endsWith(STATUSES_FOLDER)) {
                            queryFolderDocuments(treeUri, docId, projection, mediaList)
                        }
                        continue
                    }

                    if (name.startsWith(".nomedia") || name.isEmpty()) {
                        continue
                    }

                    val mediaType = classifyMedia(name, mimeType) ?: continue
                    val docUri = DocumentsContract.buildDocumentUriUsingTree(treeUri, docId)

                    mediaList.add(
                        mapOf(
                            "id" to docId,
                            "documentUri" to docUri.toString(),
                            "fileName" to name,
                            "mediaType" to mediaType,
                            "mimeType" to mimeType,
                            "size" to size,
                            "lastModified" to lastModified
                        )
                    )
                }
            }
        } catch (_: Exception) {}
    }

    private fun classifyMedia(fileName: String, mimeType: String): String? {
        val lowerMime = mimeType.lowercase()
        val lowerName = fileName.lowercase()

        // 1. Image
        if (lowerMime.startsWith("image/") ||
            lowerName.endsWith(".jpg") ||
            lowerName.endsWith(".jpeg") ||
            lowerName.endsWith(".png") ||
            lowerName.endsWith(".webp")
        ) {
            return "image"
        }

        // 2. Video
        if (lowerMime.startsWith("video/") ||
            lowerName.endsWith(".mp4") ||
            lowerName.endsWith(".3gp") ||
            lowerName.endsWith(".mkv")
        ) {
            return "video"
        }

        // 3. Audio (voice notes and audio statuses)
        if (lowerMime.startsWith("audio/") ||
            lowerName.endsWith(".opus") ||
            lowerName.endsWith(".ogg") ||
            lowerName.endsWith(".aac") ||
            lowerName.endsWith(".m4a") ||
            lowerName.endsWith(".mp3") ||
            lowerName.endsWith(".amr")
        ) {
            return "audio"
        }

        return null
    }

    private fun getThumbnail(documentUriString: String, width: Int, height: Int, result: MethodChannel.Result) {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val thumbDir = File(activity.cacheDir, "status_thumbnails").apply {
                    if (!exists()) mkdirs()
                }

                val hash = md5(documentUriString)
                val cacheFile = File(thumbDir, "$hash.jpg")

                if (cacheFile.exists() && cacheFile.length() > 0) {
                    withContext(Dispatchers.Main) {
                        result.success(cacheFile.absolutePath)
                    }
                    return@launch
                }

                val docUri = Uri.parse(documentUriString)
                var bitmap: Bitmap? = null

                // On Android 10+ (API 29+), ContentResolver.loadThumbnail is available and efficient
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    try {
                        val size = Size(width.coerceAtLeast(300), height.coerceAtLeast(300))
                        bitmap = activity.contentResolver.loadThumbnail(docUri, size, null)
                    } catch (_: Exception) {
                        // Fallback below
                    }
                }

                if (bitmap == null) {
                    // Fallback to DocumentsContract.getDocumentThumbnail or manual extraction
                    try {
                        bitmap = DocumentsContract.getDocumentThumbnail(
                            activity.contentResolver,
                            docUri,
                            android.graphics.Point(width, height),
                            null
                        )
                    } catch (_: Exception) {
                        // Manual decoding fallback
                    }
                }

                if (bitmap == null) {
                    // Try decoding file descriptor
                    try {
                        activity.contentResolver.openFileDescriptor(docUri, "r")?.use { pfd ->
                            val options = BitmapFactory.Options().apply {
                                inSampleSize = 2
                            }
                            bitmap = BitmapFactory.decodeFileDescriptor(pfd.fileDescriptor, null, options)

                            // Video frame extraction fallback for video media
                            if (bitmap == null) {
                                val retriever = MediaMetadataRetriever()
                                try {
                                    retriever.setDataSource(pfd.fileDescriptor)
                                    val targetW = width.coerceAtLeast(300)
                                    val targetH = height.coerceAtLeast(300)
                                    bitmap = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
                                        retriever.getScaledFrameAtTime(
                                            0,
                                            MediaMetadataRetriever.OPTION_CLOSEST_SYNC,
                                            targetW,
                                            targetH
                                        ) ?: retriever.getFrameAtTime(0, MediaMetadataRetriever.OPTION_CLOSEST_SYNC)
                                          ?: retriever.frameAtTime
                                          ?: retriever.getFrameAtTime(1000000, MediaMetadataRetriever.OPTION_CLOSEST_SYNC)
                                    } else {
                                        retriever.getFrameAtTime(0, MediaMetadataRetriever.OPTION_CLOSEST_SYNC)
                                            ?: retriever.frameAtTime
                                            ?: retriever.getFrameAtTime(1000000, MediaMetadataRetriever.OPTION_CLOSEST_SYNC)
                                    }
                                } finally {
                                    try {
                                        retriever.release()
                                    } catch (_: Exception) {}
                                }
                            }
                        }
                    } catch (_: Exception) {
                        // ignore and try next fallback
                    }
                }

                // Fallback to Uri-based MediaMetadataRetriever
                if (bitmap == null) {
                    try {
                        val retriever = MediaMetadataRetriever()
                        try {
                            retriever.setDataSource(activity, docUri)
                            bitmap = retriever.getFrameAtTime(0, MediaMetadataRetriever.OPTION_CLOSEST_SYNC)
                                ?: retriever.frameAtTime
                                ?: retriever.getFrameAtTime(1000000, MediaMetadataRetriever.OPTION_CLOSEST_SYNC)
                        } finally {
                            try {
                                retriever.release()
                            } catch (_: Exception) {}
                        }
                    } catch (_: Exception) {}
                }

                // Fallback to openInputStream with BufferedInputStream for images
                if (bitmap == null) {
                    try {
                        activity.contentResolver.openInputStream(docUri)?.use { input ->
                            val buffered = java.io.BufferedInputStream(input)
                            val options = BitmapFactory.Options().apply {
                                inSampleSize = 2
                            }
                            bitmap = BitmapFactory.decodeStream(buffered, null, options)
                        }
                    } catch (_: Exception) {}
                }

                // Fallback to temporary cache file for videos if PFD/URI was non-seekable
                if (bitmap == null) {
                    try {
                        val tempFile = File(thumbDir, "temp_${hash}.tmp")
                        activity.contentResolver.openInputStream(docUri)?.use { input ->
                            FileOutputStream(tempFile).use { output ->
                                input.copyTo(output, bufferSize = 64 * 1024)
                            }
                        }
                        if (tempFile.exists() && tempFile.length() > 0) {
                            val retriever = MediaMetadataRetriever()
                            try {
                                retriever.setDataSource(tempFile.absolutePath)
                                val targetW = width.coerceAtLeast(300)
                                val targetH = height.coerceAtLeast(300)
                                bitmap = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
                                    retriever.getScaledFrameAtTime(
                                        0,
                                        MediaMetadataRetriever.OPTION_CLOSEST_SYNC,
                                        targetW,
                                        targetH
                                    ) ?: retriever.getFrameAtTime(0, MediaMetadataRetriever.OPTION_CLOSEST_SYNC)
                                      ?: retriever.frameAtTime
                                } else {
                                    retriever.getFrameAtTime(0, MediaMetadataRetriever.OPTION_CLOSEST_SYNC)
                                        ?: retriever.frameAtTime
                                }
                            } finally {
                                try { retriever.release() } catch (_: Exception) {}
                                tempFile.delete()
                            }
                        }
                    } catch (_: Exception) {}
                }

                val safeBitmap = bitmap
                if (safeBitmap == null) {
                    withContext(Dispatchers.Main) {
                        result.error("THUMBNAIL_FAILED", "Could not generate thumbnail for $documentUriString", null)
                    }
                    return@launch
                }

                var currentBitmap = safeBitmap

                // Scale down if oversized
                val maxTarget = width.coerceAtLeast(height).coerceAtLeast(400)
                if (currentBitmap.width > maxTarget || currentBitmap.height > maxTarget) {
                    val scale = maxTarget.toFloat() / maxOf(currentBitmap.width, currentBitmap.height)
                    if (scale < 1.0f) {
                        val scaled = Bitmap.createScaledBitmap(
                            currentBitmap,
                            (currentBitmap.width * scale).toInt().coerceAtLeast(1),
                            (currentBitmap.height * scale).toInt().coerceAtLeast(1),
                            true
                        )
                        if (scaled != currentBitmap) {
                            currentBitmap.recycle()
                            currentBitmap = scaled
                        }
                    }
                }

                FileOutputStream(cacheFile).use { out ->
                    currentBitmap.compress(Bitmap.CompressFormat.JPEG, 80, out)
                }

                withContext(Dispatchers.Main) {
                    result.success(cacheFile.absolutePath)
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("THUMBNAIL_ERROR", "Error generating thumbnail: ${e.message}", null)
                }
            }
        }
    }

    private fun getMediaMetadata(documentUriString: String, result: MethodChannel.Result) {
        CoroutineScope(Dispatchers.IO).launch {
            val retriever = MediaMetadataRetriever()
            try {
                val uri = Uri.parse(documentUriString)
                activity.contentResolver.openFileDescriptor(uri, "r")?.use { pfd ->
                    retriever.setDataSource(pfd.fileDescriptor)
                    val durationStr = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
                    val widthStr = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH)
                    val heightStr = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT)
                    val mimeType = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_MIMETYPE)

                    val durationMs = durationStr?.toLongOrNull() ?: 0L
                    val width = widthStr?.toIntOrNull() ?: 0
                    val height = heightStr?.toIntOrNull() ?: 0

                    val metadata = mapOf(
                        "durationMs" to durationMs,
                        "width" to width,
                        "height" to height,
                        "mimeType" to (mimeType ?: "")
                    )

                    withContext(Dispatchers.Main) {
                        result.success(metadata)
                    }
                } ?: run {
                    withContext(Dispatchers.Main) {
                        result.error("FILE_NOT_FOUND", "Could not open file descriptor", null)
                    }
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("METADATA_ERROR", "Failed to retrieve metadata: ${e.message}", null)
                }
            } finally {
                try {
                    retriever.release()
                } catch (_: Exception) {}
            }
        }
    }

    private fun saveToMediaStore(
        documentUriString: String,
        mediaType: String,
        fileName: String,
        isBusiness: Boolean,
        customTreeUri: String?,
        result: MethodChannel.Result
    ) {
        CoroutineScope(Dispatchers.IO).launch {
            var insertedUri: Uri? = null
            try {
                val sourceUri = Uri.parse(documentUriString)
                val resolver = activity.contentResolver

                val subFolder: String
                val extension: String
                val defaultMimeType: String

                when (mediaType.lowercase()) {
                    "video", "videos" -> {
                        subFolder = "Halati Videos"
                        extension = if (fileName.contains('.')) "" else ".mp4"
                        defaultMimeType = "video/mp4"
                    }
                    "audio", "audios" -> {
                        subFolder = "Halati Audios"
                        extension = if (fileName.contains('.')) "" else ".ogg"
                        defaultMimeType = "audio/ogg"
                    }
                    else -> {
                        subFolder = "Halati Images"
                        extension = if (fileName.contains('.')) "" else ".jpg"
                        defaultMimeType = "image/jpeg"
                    }
                }

                val detectedMimeType = try {
                    resolver.getType(sourceUri)
                } catch (_: Exception) {
                    null
                }

                val mimeType = if (!detectedMimeType.isNullOrBlank() && detectedMimeType != "application/octet-stream") {
                    detectedMimeType
                } else {
                    defaultMimeType
                }

                val fullFileName = if (fileName.endsWith(extension) || extension.isEmpty()) fileName else "$fileName$extension"

                // 1. Try custom folder if specified and valid
                if (!customTreeUri.isNullOrEmpty()) {
                    try {
                        val treeUri = Uri.parse(customTreeUri)
                        val parentDoc = DocumentFile.fromTreeUri(activity, treeUri)
                        if (parentDoc != null && parentDoc.exists() && parentDoc.canWrite()) {
                            val subDir = parentDoc.findFile(subFolder) ?: parentDoc.createDirectory(subFolder) ?: parentDoc
                            val existing = subDir.findFile(fullFileName)
                            val targetDoc = existing ?: subDir.createFile(mimeType, fullFileName)
                                ?: throw Exception("Could not create file in $subFolder")

                            resolver.openInputStream(sourceUri)?.use { input ->
                                resolver.openOutputStream(targetDoc.uri)?.use { output ->
                                    input.copyTo(output, bufferSize = 64 * 1024)
                                } ?: throw Exception("Could not open custom output stream")
                            } ?: throw Exception("Could not open source input stream")

                            val friendlyParent = getFriendlyPath(activity, treeUri)
                            val response = mapOf(
                                "savedUri" to targetDoc.uri.toString(),
                                "relativePath" to "$friendlyParent/$subFolder/",
                                "fileName" to fullFileName
                            )
                            withContext(Dispatchers.Main) {
                                result.success(response)
                            }
                            return@launch
                        }
                    } catch (_: Exception) {
                        // Fall back to default directory
                    }
                }

                // 2. Default directory
                val appName = if (isBusiness) "WhatsApp Business" else "WhatsApp"
                val relativePath = "${Environment.DIRECTORY_DOWNLOADS}/Halati/$appName/$subFolder/"

                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
                    val downloadsDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
                    val destDir = File(downloadsDir, "Halati/$appName/$subFolder").apply {
                        if (!exists()) mkdirs()
                    }
                    val destFile = File(destDir, fullFileName)

                    resolver.openInputStream(sourceUri)?.use { input: InputStream ->
                        FileOutputStream(destFile).use { output ->
                            input.copyTo(output, bufferSize = 64 * 1024)
                        }
                    } ?: throw Exception("Could not open source input stream")

                    android.media.MediaScannerConnection.scanFile(
                        activity,
                        arrayOf(destFile.absolutePath),
                        arrayOf(mimeType),
                        null
                    )

                    val response = mapOf(
                        "savedUri" to Uri.fromFile(destFile).toString(),
                        "relativePath" to relativePath,
                        "fileName" to fullFileName
                    )

                    withContext(Dispatchers.Main) {
                        result.success(response)
                    }
                    return@launch
                }

                // Android 10+ (API 29+): MediaStore.Downloads
                val targetCollection = MediaStore.Downloads.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
                val contentValues = ContentValues().apply {
                    put(MediaStore.MediaColumns.DISPLAY_NAME, fullFileName)
                    put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
                    put(MediaStore.MediaColumns.RELATIVE_PATH, relativePath)
                    put(MediaStore.MediaColumns.IS_PENDING, 1)
                }

                insertedUri = try {
                    resolver.insert(targetCollection, contentValues)
                } catch (_: Exception) {
                    null
                }

                if (insertedUri == null) {
                    val baseName = if (fullFileName.contains('.')) fullFileName.substringBeforeLast('.') else fullFileName
                    val ext = if (fullFileName.contains('.')) ".${fullFileName.substringAfterLast('.')}" else ""
                    val uniqueFileName = "${baseName}_${System.currentTimeMillis()}$ext"
                    contentValues.put(MediaStore.MediaColumns.DISPLAY_NAME, uniqueFileName)
                    insertedUri = resolver.insert(targetCollection, contentValues)
                }

                if (insertedUri == null) {
                    throw Exception("MediaStore insert returned null URI")
                }

                // Copy stream
                resolver.openInputStream(sourceUri)?.use { input: InputStream ->
                    resolver.openOutputStream(insertedUri)?.use { output ->
                        input.copyTo(output, bufferSize = 64 * 1024)
                    } ?: throw Exception("Could not open MediaStore output stream")
                } ?: throw Exception("Could not open source input stream")

                // Update IS_PENDING on Android 10+
                contentValues.clear()
                contentValues.put(MediaStore.MediaColumns.IS_PENDING, 0)
                resolver.update(insertedUri, contentValues, null, null)

                val response = mapOf(
                    "savedUri" to insertedUri.toString(),
                    "relativePath" to relativePath,
                    "fileName" to fullFileName
                )

                withContext(Dispatchers.Main) {
                    result.success(response)
                }
            } catch (e: Exception) {
                // Cleanup partial write
                if (insertedUri != null) {
                    try {
                        activity.contentResolver.delete(insertedUri, null, null)
                    } catch (_: Exception) {}
                }
                withContext(Dispatchers.Main) {
                    result.error("SAVE_FAILED", "Failed to save to gallery: ${e.message}", null)
                }
            }
        }
    }

    private fun deleteFromMediaStore(mediaStoreUriString: String, result: MethodChannel.Result) {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val uri = Uri.parse(mediaStoreUriString)
                val resolver = activity.contentResolver
                if (uri.scheme == "file") {
                    val file = File(uri.path ?: "")
                    if (file.exists()) {
                        file.delete()
                    }
                } else if (DocumentsContract.isDocumentUri(activity, uri)) {
                    DocumentsContract.deleteDocument(resolver, uri)
                } else {
                    try {
                        resolver.delete(uri, null, null)
                    } catch (_: Exception) {
                        val doc = DocumentFile.fromSingleUri(activity, uri)
                        if (doc != null && doc.exists()) {
                            doc.delete()
                        }
                    }
                }
                withContext(Dispatchers.Main) {
                    result.success(true)
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("DELETE_FAILED", "Failed to delete: ${e.message}", null)
                }
            }
        }
    }

    private fun getFullMediaFile(documentUriString: String, fileName: String, result: MethodChannel.Result) {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val fullDir = File(activity.cacheDir, "status_full").apply {
                    if (!exists()) mkdirs()
                }

                val ext = if (fileName.contains('.')) fileName.substringAfterLast('.', "") else ""
                val extWithDot = if (ext.isNotEmpty()) ".$ext" else ""
                val hash = md5(documentUriString)
                val targetFile = File(fullDir, "$hash$extWithDot")

                if (targetFile.exists() && targetFile.length() > 0) {
                    withContext(Dispatchers.Main) {
                        result.success(targetFile.absolutePath)
                    }
                    return@launch
                }

                val sourceUri = Uri.parse(documentUriString)
                activity.contentResolver.openInputStream(sourceUri)?.use { input ->
                    FileOutputStream(targetFile).use { output ->
                        input.copyTo(output, bufferSize = 64 * 1024)
                    }
                } ?: throw Exception("Could not open input stream for $documentUriString")

                withContext(Dispatchers.Main) {
                    result.success(targetFile.absolutePath)
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.error("COPY_FAILED", "Failed to cache media file: ${e.message}", null)
                }
            }
        }
    }

    private fun md5(input: String): String {
        val md = MessageDigest.getInstance("MD5")
        val bytes = md.digest(input.toByteArray())
        return bytes.joinToString("") { "%02x".format(it) }
    }
}
