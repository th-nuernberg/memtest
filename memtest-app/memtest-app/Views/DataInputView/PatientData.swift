//
//  PatientData.swift
//  memtest-app
//
//  Created by Christopher Witzl on 27.04.24.
//

import Foundation

class PatientData: ObservableObject {
    @Published var age: String = ""
    @Published var selectedDegree: EducationalQualification = .noDegree
    @Published var selectedGender: Gender = .male
    @Published var hasVisionProblems: Bool = false
    @Published var hasHearingProblems: Bool = false
    @Published var dementiaSeverity: Severity = .none
    @Published var depressionSeverity: Severity = .none
    @Published var additionalDiagnoses: String = ""
}



enum EducationalQualification: String, RadioButtonType {
    case noDegree = "Kein Abschluss"
    case schoolOrApprenticeship = "Schulabschluss, Ausbildungsberuf"
    case technicianMasterOrUniversity = "Techniker, Meister oder Hochschulabschluss"
    
    static var allCases: [EducationalQualification] {
        return [.noDegree, .schoolOrApprenticeship, .technicianMasterOrUniversity]
    }
    
    var id: String {
        return rawValue
    }
    var displayValue: String { self.rawValue }
}

enum Gender: String, RadioButtonType {
    case male = "Männlich"
    case female = "Weiblich"
    
    static var allCases: [Gender] {
        return [.male, .female]
    }
    
    var id: String {
        return rawValue
    }
    
    var displayValue: String { self.rawValue }
}

enum Severity: String, RadioButtonType {
    case none = "Keine"
    case mild = "Leichte"
    case moderate = "Mittelschwere"
    case severe = "Schwere"

    var id: String { rawValue }
    var displayValue: String { self.rawValue }
}
