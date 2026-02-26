package com.tummyboy.data.location

data class RunSession(
    val id: Long,
    val distanceMeters: Double,
    val durationSeconds: Long,
    val startedAtMillis: Long
)
