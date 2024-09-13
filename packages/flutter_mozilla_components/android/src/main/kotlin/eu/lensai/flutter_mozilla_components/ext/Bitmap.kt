package eu.lensai.flutter_mozilla_components.ext

import android.graphics.Bitmap
import android.os.Build
import java.io.ByteArrayOutputStream

fun Bitmap.toWebPBytes(): ByteArray {
    val stream = ByteArrayOutputStream()
    val compressFormat = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
        Bitmap.CompressFormat.WEBP_LOSSLESS
    } else {
        @Suppress("DEPRECATION")
        Bitmap.CompressFormat.WEBP
    }
    compress(compressFormat, 100, stream)
    return stream.toByteArray()
}