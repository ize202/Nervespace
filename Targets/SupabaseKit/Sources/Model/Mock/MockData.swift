import Foundation

public extension Routine {
    static let mockWakeAndShake = Routine(
        id: UUID(),
        name: "Wake & Shake 1",
        description: "An energizing routine that uses dynamic stretches and mobility exercises to prime your body for an active, productive day ahead.",
        thumbnailURL: nil,
        isPremium: false,
        createdAt: Date(),
        updatedAt: Date()
    )
    
    static let mockEveningUnwind = Routine(
        id: UUID(),
        name: "Evening Unwind",
        description: "A calming sequence of gentle movements and breathing exercises to help you relax and prepare for restful sleep.",
        thumbnailURL: nil,
        isPremium: true,
        createdAt: Date(),
        updatedAt: Date()
    )
    
    static let mockQuickReset = Routine(
        id: UUID(),
        name: "Midday Reset",
        description: "A quick energizing sequence to break up your day and restore focus.",
        thumbnailURL: nil,
        isPremium: false,
        createdAt: Date(),
        updatedAt: Date()
    )
    
    static let allMocks = [mockWakeAndShake, mockEveningUnwind, mockQuickReset]
    
    static let mockPlans = [
        Routine(
            id: UUID(),
            name: "Beginner Series",
            description: "A 3-day series designed to introduce you to basic somatic practices",
            thumbnailURL: nil,
            isPremium: false,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Routine(
            id: UUID(),
            name: "Stress Relief",
            description: "A 5-day series focused on reducing stress and anxiety",
            thumbnailURL: nil,
            isPremium: true,
            createdAt: Date(),
            updatedAt: Date()
        ),
        Routine(
            id: UUID(),
            name: "Better Sleep",
            description: "A 7-day series to improve your sleep quality",
            thumbnailURL: nil,
            isPremium: true,
            createdAt: Date(),
            updatedAt: Date()
        )
    ]
}

public extension Exercise {
    static let mockDynamicSideBends = Exercise(
        id: UUID(),
        name: "Dynamic Side Bends",
        description: "Stretch your obliques with controlled side bends",
        instructions: "1. Stand with feet hip-width apart\n2. Raise your arms overhead\n3. Bend sideways, reaching your arm down your leg\n4. Return to center and repeat on other side",
        thumbnailURL: nil,
        animationURL: nil,
        videoURL: nil,
        previewURL: nil,
        baseDuration: 30,
        createdAt: Date(),
        updatedAt: Date()
    )
    
    static let mockArmCircles = Exercise(
        id: UUID(),
        name: "Arm Circles",
        description: "Rotate your arms in circles to warm up shoulders",
        instructions: "1. Stand with feet shoulder-width apart\n2. Extend arms out to sides\n3. Make small circles forward for 15 seconds\n4. Reverse direction for 15 seconds",
        thumbnailURL: nil,
        animationURL: nil,
        videoURL: nil,
        previewURL: nil,
        baseDuration: 30,
        createdAt: Date(),
        updatedAt: Date()
    )
    
    static let mockNeckRoll = Exercise(
        id: UUID(),
        name: "Neck Roll",
        description: "Gently roll your neck to release tension",
        instructions: "1. Start with your chin to chest\n2. Slowly roll your head to the right shoulder\n3. Roll back to center\n4. Roll to left shoulder\n5. Return to center",
        thumbnailURL: nil,
        animationURL: nil,
        videoURL: nil,
        previewURL: nil,
        baseDuration: 30,
        createdAt: Date(),
        updatedAt: Date()
    )
    
    static let mockTrunkTwist = Exercise(
        id: UUID(),
        name: "Trunk Twist",
        description: "Rotate your torso to improve spinal mobility",
        instructions: "1. Stand with feet hip-width apart\n2. Keep hips facing forward\n3. Slowly twist torso to the right\n4. Return to center\n5. Twist to the left\n6. Return to center",
        thumbnailURL: nil,
        animationURL: nil,
        videoURL: nil,
        previewURL: nil,
        baseDuration: 30,
        createdAt: Date(),
        updatedAt: Date()
    )
    
    static let mockHipCircles = Exercise(
        id: UUID(),
        name: "Hip Circles",
        description: "Move your hips in circles to improve mobility",
        instructions: "1. Stand with feet wider than hip-width\n2. Place hands on hips\n3. Make slow circles with your hips\n4. Change direction halfway through",
        thumbnailURL: nil,
        animationURL: nil,
        videoURL: nil,
        previewURL: nil,
        baseDuration: 30,
        createdAt: Date(),
        updatedAt: Date()
    )
    
    static let allMocks = [
        mockDynamicSideBends,
        mockArmCircles,
        mockNeckRoll,
        mockTrunkTwist,
        mockHipCircles
    ]
}

public extension Dictionary where Key == UUID, Value == [Exercise] {
    static let mockRoutineExercises: [UUID: [Exercise]] = [
        Routine.mockWakeAndShake.id: [
            Exercise.mockDynamicSideBends,
            Exercise.mockArmCircles,
            Exercise.mockNeckRoll,
            Exercise.mockTrunkTwist,
            Exercise.mockHipCircles
        ],
        Routine.mockEveningUnwind.id: [
            Exercise.mockNeckRoll,
            Exercise.mockDynamicSideBends,
            Exercise.mockHipCircles
        ],
        Routine.mockQuickReset.id: [
            Exercise.mockTrunkTwist,
            Exercise.mockArmCircles
        ],
        Routine.mockPlans[0].id: [ // Beginner Series
            Exercise.mockNeckRoll,
            Exercise.mockArmCircles,
            Exercise.mockDynamicSideBends
        ],
        Routine.mockPlans[1].id: [ // Stress Relief
            Exercise.mockHipCircles,
            Exercise.mockNeckRoll,
            Exercise.mockTrunkTwist
        ],
        Routine.mockPlans[2].id: [ // Better Sleep
            Exercise.mockDynamicSideBends,
            Exercise.mockHipCircles,
            Exercise.mockNeckRoll
        ]
    ]
}

public extension Dictionary where Key == UUID, Value == [String] {
    static let mockExerciseTags: [UUID: [String]] = [
        Exercise.mockDynamicSideBends.id: ["Movement", "Stress Relief", "Focus & Clarity"],
        Exercise.mockArmCircles.id: ["Movement", "Energy Boost", "Quick Reset"],
        Exercise.mockNeckRoll.id: ["Movement", "Stress Relief", "Better Sleep"],
        Exercise.mockTrunkTwist.id: ["Movement", "Energy Boost", "Quick Reset"],
        Exercise.mockHipCircles.id: ["Movement", "Stress Relief", "Anxiety"]
    ]
}

public extension Plan {
    static let mockMorningRoutine = Plan(
        name: "Morning Routine",
        description: "A series designed to help you build a consistent routine and improve your overall well-being.",
        isPremium: false,
        duration: "7 DAY SERIES",
        routines: [
            Routine.mockWakeAndShake,
            Routine.mockEveningUnwind,
            Routine.mockQuickReset,
            // Create more routines for the remaining days
            Routine(
                id: UUID(),
                name: "Energy Flow",
                description: "Dynamic movements to energize your body",
                thumbnailURL: nil,
                isPremium: false,
                createdAt: Date(),
                updatedAt: Date()
            ),
            Routine(
                id: UUID(),
                name: "Morning Stretch",
                description: "Gentle stretches to wake up your body",
                thumbnailURL: nil,
                isPremium: false,
                createdAt: Date(),
                updatedAt: Date()
            ),
            Routine(
                id: UUID(),
                name: "Rise & Shine",
                description: "Start your day with invigorating movements",
                thumbnailURL: nil,
                isPremium: false,
                createdAt: Date(),
                updatedAt: Date()
            ),
            Routine(
                id: UUID(),
                name: "Dawn Flow",
                description: "Flow through energizing movements",
                thumbnailURL: nil,
                isPremium: false,
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
    )
    
    static let mockStressRelief = Plan(
        name: "Stress Relief",
        description: "A targeted program to help you manage and reduce stress through mindful movement.",
        isPremium: true,
        duration: "5 DAY SERIES",
        routines: [
            Routine(
                id: UUID(),
                name: "Tension Release",
                description: "Release physical tension from your body",
                thumbnailURL: nil,
                isPremium: true,
                createdAt: Date(),
                updatedAt: Date()
            ),
            Routine(
                id: UUID(),
                name: "Calm & Center",
                description: "Find your center with grounding exercises",
                thumbnailURL: nil,
                isPremium: true,
                createdAt: Date(),
                updatedAt: Date()
            ),
            Routine(
                id: UUID(),
                name: "Mindful Movement",
                description: "Connect movement with breath",
                thumbnailURL: nil,
                isPremium: true,
                createdAt: Date(),
                updatedAt: Date()
            ),
            Routine(
                id: UUID(),
                name: "Stress Melt",
                description: "Melt away stress with gentle flows",
                thumbnailURL: nil,
                isPremium: true,
                createdAt: Date(),
                updatedAt: Date()
            ),
            Routine(
                id: UUID(),
                name: "Deep Release",
                description: "Deep relaxation and tension release",
                thumbnailURL: nil,
                isPremium: true,
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
    )
    
    static let allMockPlans = [mockMorningRoutine, mockStressRelief]
}

public extension Dictionary where Key == UUID, Value == [Exercise] {
    static let mockPlanExercises: [UUID: [Exercise]] = [
        Plan.mockMorningRoutine.id: [
            Exercise.mockDynamicSideBends,
            Exercise.mockArmCircles,
            Exercise.mockNeckRoll,
            Exercise.mockTrunkTwist,
            Exercise.mockHipCircles
        ],
        Plan.mockStressRelief.id: [
            Exercise.mockNeckRoll,
            Exercise.mockDynamicSideBends,
            Exercise.mockHipCircles
        ]
    ]
} 