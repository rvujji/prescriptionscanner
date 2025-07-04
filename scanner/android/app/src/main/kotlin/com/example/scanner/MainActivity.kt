//Raj: Code changed by Raj to support notifications
package com.example.scanner
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import androidx.core.app.NotificationManagerCompat

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Ensure notification channel is created
        NotificationManagerCompat.from(this).areNotificationsEnabled()
    }
}
