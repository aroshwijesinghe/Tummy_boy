package com.tummyboy.data.local

data class WorkoutEntry(
    val id: Long,
    val type: String,
    val count: Int,
    val timestampMillis: Long
)
