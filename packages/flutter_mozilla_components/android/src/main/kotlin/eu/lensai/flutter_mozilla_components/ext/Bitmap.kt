package eu.lensai.flutter_mozilla_components.ext

import android.graphics.Bitmap
import android.os.Build
import java.io.ByteArrayOutputStream

fun Bitmap.resize(maxWidth: Int, maxHeight: Int): Bitmap {
    var width = this.width
    var height = this.height

    val aspectRatio: Float = width.toFloat() / height.toFloat()

    if (width > height) {
        width = maxWidth
        height = (width / aspectRatio).toInt()
    } else {
        height = maxHeight
        width = (height * aspectRatio).toInt()
    }

    return Bitmap.createScaledBitmap(this, width, height, true)
}

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