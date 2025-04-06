import Foundation

public enum ExerciseLibrary {
    // MARK: - All Exercises
    public static let exercises: [Exercise] = [
        // Static Stretching Exercises
        Exercise(
            name: "Butterfly Stretch",
            description: "A seated stretch that targets the groin and inner thighs.",
            instructions: """
            Sit with feet together and knees bent.
            Use elbows to gently press knees towards the floor.
            Keep your back straight and breathe deeply.
            """,
            modifications: "Place cushions under knees for support or sit on a folded blanket to elevate hips.",
            benefits: "Improves hip flexibility and relieves tension in the groin area.",
            categories: [.staticStretching],
            positions: [.seated],
            areas: [.groin, .hips],
            duration: 30
        ),
        
        Exercise(
            name: "Child's Pose",
            description: "A restorative pose that stretches the lower back and hips.",
            instructions: """
            Kneel on the floor and sit back on heels.
            Stretch arms forward and rest your forehead on the ground.
            Breathe deeply and relax your entire body.
            """,
            modifications: "Use a cushion under your chest for additional support.",
            benefits: "Relieves tension in the back and hips, promotes relaxation.",
            categories: [.staticStretching],
            positions: [.floor],
            areas: [.lowerBack, .hips],
            duration: 30
        ),
        
        Exercise(
            name: "Seated Forward Fold",
            description: "A stretch for the hamstrings and lower back.",
            instructions: """
            Sit with legs extended forward, reach hands towards feet.
            Keep your back straight and fold forward.
            Breathe deeply as you hold the stretch.
            """,
            modifications: "Use a strap around the feet for assistance.",
            benefits: "Increases flexibility and reduces back tension.",
            categories: [.staticStretching],
            positions: [.seated],
            areas: [.hamstrings, .lowerBack],
            duration: 30
        ),
        
        // Dynamic Stretching Exercises
        Exercise(
            name: "Seated Side Bends",
            description: "A dynamic stretch that targets the obliques and spine.",
            instructions: """
            Stand with feet shoulder-width apart.
            Alternate bending to each side while extending the opposite arm overhead.
            Keep movements controlled and breathe rhythmically.
            """,
            modifications: "Perform slowly for a gentler stretch.",
            benefits: "Increases flexibility and range of motion in the side body.",
            categories: [.dynamicStretching],
            positions: [.standing],
            areas: [.obliques, .spine],
            duration: 30
        ),
        
        Exercise(
            name: "Leg Swings",
            description: "A dynamic movement targeting the hips and hamstrings.",
            instructions: """
            Stand on one leg and swing the opposite leg forward and backward.
            Maintain a controlled motion and balance.
            Focus on smooth, continuous swings.
            """,
            modifications: "Hold onto a support for balance.",
            benefits: "Enhances hip mobility and warms up the legs.",
            categories: [.dynamicStretching],
            positions: [.standing],
            areas: [.hips, .hamstrings],
            duration: 30
        ),
        
        Exercise(
            name: "Plank Hold",
            description: "An isometric exercise that strengthens the core and arms.",
            instructions: """
            Start in a push-up position with forearms on the ground.
            Align elbows under shoulders and keep body straight from head to heels.
            Engage your core and hold the position, breathing steadily.
            """,
            modifications: "Lower knees to the ground for a modified version.",
            benefits: "Builds core stability and arm strength.",
            categories: [.isometrics],
            positions: [.floor],
            areas: [.core, .triceps, .forearms],
            duration: 30
        ),
        
        Exercise(
            name: "Wall Sit",
            description: "An isometric exercise that targets the quadriceps and calves.",
            instructions: """
            Lean against a wall and slide down into a seated position.
            Keep your thighs parallel to the ground.
            Hold and breathe steadily, engaging your core and legs.
            """,
            modifications: "Adjust the depth of the squat for comfort.",
            benefits: "Strengthens the legs and improves endurance.",
            categories: [.isometrics],
            positions: [.standing],
            areas: [.quadriceps, .calves],
            duration: 30
        ),
        
        Exercise(
            name: "Cat Cow",
            description: "A gentle flow that stretches the spine and core.",
            instructions: """
            Start on hands and knees, wrists under shoulders, knees under hips.
            Inhale, arch your back and look up (Cow).
            Exhale, round your back and tuck chin to chest (Cat).
            Move smoothly with each breath.
            """,
            modifications: "Perform slowly to focus on breath and movement.",
            benefits: "Increases spinal flexibility and reduces tension.",
            categories: [.somatic],
            positions: [.floor],
            areas: [.spine, .core],
            duration: 60
        ),
        
        Exercise(
            name: "Deep Breathing",
            description: "A breathwork exercise for stress relief.",
            instructions: """
            Sit comfortably with a straight back.
            Inhale deeply through the nose, filling your lungs for 6s.
            Exhale slowly through the mouth for 6s.
            Focus on the rhythm of your breath.
            """,
            modifications: "Use a guided audio for assistance.",
            benefits: "Promotes relaxation and reduces stress.",
            categories: [.somatic],
            positions: [.seated],
            areas: [.core],
            duration: 30
        ),
        
        Exercise(
            name: "Air Squats",
            description: "A bodyweight exercise targeting the legs and glutes.",
            instructions: """
            Stand with feet shoulder-width apart.
            Lower into a squat, keeping chest up and knees aligned over toes.
            Rise back up and repeat, breathing naturally.
            """,
            modifications: "Use a chair for support if needed.",
            benefits: "Strengthens the lower body and improves balance.",
            categories: [.calisthenics],
            positions: [.standing],
            areas: [.quadriceps, .glutes],
            duration: 30
        ),
        
        Exercise(
            name: "Bear Hug",
            description: "A movement that targets the shoulders, chest, and arms.",
            instructions: """
            Stand and wrap arms around yourself, like a hug.
            Open arms wide and repeat, feeling the stretch in shoulders and chest.
            Breathe deeply and maintain a gentle rhythm.
            """,
            modifications: "Perform slowly for a gentler stretch.",
            benefits: "Opens up the chest and relieves tension in shoulders and arms.",
            categories: [.calisthenics],
            positions: [.standing],
            areas: [.shoulders, .chest, .biceps, .forearms],
            duration: 30
        ),
        
        Exercise(
            name: "Hip Circles",
            description: "A mobility exercise targeting the hips.",
            instructions: """
            Stand with feet hip-width apart.
            Rotate hips in a circular motion, both clockwise and counterclockwise.
            Keep the movement fluid and controlled.
            """,
            modifications: "Perform smaller circles for less intensity.",
            benefits: "Increases hip mobility and flexibility.",
            categories: [.mobility],
            positions: [.standing],
            areas: [.hips],
            duration: 30
        ),
        
        Exercise(
            name: "Neck Rolls",
            description: "A gentle movement that targets the neck.",
            instructions: """
            Sit with a straight back.
            Slowly roll your head in a circular motion, both directions.
            Breathe deeply and relax your neck muscles.
            """,
            modifications: "Perform smaller circles for comfort.",
            benefits: "Relieves neck tension and improves flexibility.",
            categories: [.mobility],
            positions: [.seated],
            areas: [.neck],
            duration: 30
        ),
        
        Exercise(
            name: "Downward Dog",
            description: "A yoga pose that stretches the hamstrings, calves, and strengthens the arms.",
            instructions: """
            Start on hands and knees, tuck toes, and lift hips up and back.
            Form an inverted V-shape, pressing heels towards the floor.
            Relax your head between your arms and breathe deeply.
            """,
            modifications: "Bend knees slightly if you feel strain in hamstrings.",
            benefits: "Strengthens and stretches the entire body, including arms.",
            categories: [.yoga],
            positions: [.floor],
            areas: [.hamstrings, .calves, .triceps, .forearms],
            duration: 30
        ),
        
        Exercise(
            name: "Warrior I",
            description: "A yoga pose that targets the legs, core, and arms.",
            instructions: """
            Step one foot forward into a lunge, bending the front knee.
            Raise arms overhead and square hips forward.
            Hold the pose, breathing steadily.
            """,
            modifications: "Shorten the stance for better balance.",
            benefits: "Builds strength and stability throughout the body.",
            categories: [.yoga],
            positions: [.standing],
            areas: [.quadriceps, .core, .shoulders, .triceps],
            duration: 30
        ),
        
        Exercise(
            name: "Bridge Pose",
            description: "A backbend that targets the glutes and lower back.",
            instructions: """
            Lie on your back with knees bent and feet flat.
            Lift hips towards the ceiling, keeping shoulders grounded.
            Hold and breathe deeply, engaging your glutes.
            """,
            modifications: "Place a block under hips for support.",
            benefits: "Strengthens the back and opens the chest.",
            categories: [.yoga],
            positions: [.floor],
            areas: [.glutes, .lowerBack],
            duration: 30
        ),
        
        Exercise(
            name: "Jumping Jacks",
            description: "A full-body cardio exercise.",
            instructions: """
            Stand tall, jump with legs apart and arms overhead.
            Return to starting position and repeat.
            Maintain a rhythmic pace and breathe naturally.
            """,
            modifications: "Step side-to-side instead of jumping.",
            benefits: "Increases heart rate and improves cardiovascular endurance.",
            categories: [.cardio],
            positions: [.standing],
            areas: [.core, .quadriceps, .shoulders, .triceps],
            duration: 30
        ),
        
        Exercise(
            name: "High Knees",
            description: "A cardio exercise targeting the core and legs.",
            instructions: """
            Stand and run in place, lifting knees high towards the chest.
            Keep core engaged and arms active.
            Maintain a steady pace and breathe rhythmically.
            """,
            modifications: "March in place for a lower intensity.",
            benefits: "Boosts cardiovascular fitness and leg strength.",
            categories: [.cardio],
            positions: [.standing],
            areas: [.core, .quadriceps],
            duration: 30
        ),
        
        Exercise(
            name: "Lying Figure Four",
            description: "A stretch targeting the hips and glutes.",
            instructions: """
            Lie on your back, cross one ankle over opposite knee.
            Pull the leg towards the chest, feeling a stretch in the hip.
            Breathe deeply and hold the position.
            """,
            modifications: "Keep the foot on the ground for less intensity.",
            benefits: "Improves hip flexibility and relieves tension.",
            categories: [.mobility],
            positions: [.floor],
            areas: [.hips, .glutes],
            duration: 30
        ),
        
        Exercise(
            name: "Happy Baby Pose",
            description: "A restorative pose targeting the lower back and hips.",
            instructions: """
            Lie on your back, bend knees and hold feet.
            Gently pull knees towards the armpits.
            Breathe deeply and relax your lower back.
            """,
            modifications: "Hold the back of thighs if unable to reach feet.",
            benefits: "Relaxes the lower back and opens the hips.",
            categories: [.yoga],
            positions: [.floor],
            areas: [.lowerBack, .hips],
            duration: 30
        )
    ]
    
    // MARK: - Category Helpers
    public static func exercises(for category: ExerciseCategory) -> [Exercise] {
        exercises.filter { $0.categories.contains(category) }
    }
    
    public static var staticStretchingExercises: [Exercise] {
        exercises(for: .staticStretching)
    }
    
    public static var somaticExercises: [Exercise] {
        exercises(for: .somatic)
    }
    
    // MARK: - Area Helpers
    public static func exercises(for area: ExerciseArea) -> [Exercise] {
        exercises.filter { $0.areas.contains(area) }
    }
    
    public static var neckExercises: [Exercise] {
        exercises(for: .neck)
    }
    
    public static var shoulderExercises: [Exercise] {
        exercises(for: .shoulders)
    }
    
    // MARK: - Position Helpers
    public static func exercises(for position: ExercisePosition) -> [Exercise] {
        exercises.filter { $0.positions.contains(position) }
    }
    
    public static var seatedExercises: [Exercise] {
        exercises(for: .seated)
    }
    
    public static var standingExercises: [Exercise] {
        exercises(for: .standing)
    }
    
    // MARK: - Search Helpers
    public static func exercise(withId id: String) -> Exercise? {
        exercises.first { $0.id == id }
    }
    
    public static func search(_ query: String) -> [Exercise] {
        let terms = query.lowercased().split(separator: " ").map(String.init)
        return exercises.filter { exercise in
            terms.contains { term in
                exercise.name.lowercased().contains(term) ||
                exercise.description.lowercased().contains(term) ||
                exercise.categories.contains { $0.rawValue.lowercased().contains(term) } ||
                exercise.areas.contains { $0.rawValue.lowercased().contains(term) }
            }
        }
    }
} 
