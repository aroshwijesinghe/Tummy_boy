package com.tummyboy.ml

import com.tummyboy.domain.UserProfile

interface ExerciseRecommendationEngine {
    fun recommend(profile: UserProfile): String
}
