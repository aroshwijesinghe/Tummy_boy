package com.tummyboy

import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.tummyboy.ui.screens.home.HomeScreen
import com.tummyboy.ui.screens.profile.ProfileScreen
import com.tummyboy.ui.screens.reports.ReportsScreen
import com.tummyboy.ui.screens.run.RunTrackingScreen
import com.tummyboy.ui.screens.workout.WorkoutLogScreen

@Composable
fun TummyBoyApp() {
    val navController = rememberNavController()

    Surface(
        modifier = Modifier.fillMaxSize(),
        color = MaterialTheme.colorScheme.background
    ) {
        NavHost(
            navController = navController,
            startDestination = "home"
        ) {
            composable("home") { HomeScreen() }
            composable("workout") { WorkoutLogScreen() }
            composable("run") { RunTrackingScreen() }
            composable("reports") { ReportsScreen() }
            composable("profile") { ProfileScreen() }
            composable("recommendation") {
                Text(text = "Recommendation screen coming soon")
            }
        }
    }
}
