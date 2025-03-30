import Foundation

public enum ExerciseCategory: String, CaseIterable {
    case staticStretching = "Static stretching"
    case dynamicStretching = "Dynamic stretching"
    case isometrics = "Isometrics"
    case somatic = "Somatic"
    case calisthenics = "Calisthenics"
    case mobility = "Mobility"
    case yoga = "Yoga"
    case cardio = "Cardio"
}

public enum ExercisePosition: String, CaseIterable {
    case standing = "Standing"
    case seated = "Seated"
    case floor = "Floor"
}

public enum ExerciseArea: String, CaseIterable {
    case abdomen = "Abdomen"
    case ankles = "Ankles"
    case biceps = "Biceps"
    case calves = "Calves"
    case chest = "Chest"
    case core = "Core"
    case feet = "Feet"
    case fingers = "Fingers"
    case forearms = "Forearms"
    case glutes = "Glutes"
    case groin = "Groin"
    case hamstrings = "Hamstrings"
    case hands = "Hands"
    case hips = "Hips"
    case itBand = "IT Band"
    case knees = "Knees"
    case lats = "Lats"
    case lowerBack = "Lower Back"
    case neck = "Neck"
    case obliques = "Obliques"
    case psoas = "Psoas"
    case quadriceps = "Quadriceps"
    case shins = "Shins"
    case shoulders = "Shoulders"
    case spine = "Spine"
    case toes = "Toes"
    case triceps = "Triceps"
    case upperBack = "Upper Back"
    case wrists = "Wrists"
} 