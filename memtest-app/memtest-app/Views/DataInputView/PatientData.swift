//
//  PatientData.swift
//  memtest-app
//
//  Created by Christopher Witzl on 27.04.24.
//

import Foundation

// defines structures for saving the patient data from the DataInputViews

class PatientData: ObservableObject, Encodable {
    @Published var age: String = ""
    @Published var selectedDegree: EducationalQualification = .noDegree
    @Published var selectedGender: Gender = .male
    @Published var hasVisionProblems: Bool = false
    @Published var hasHearingProblems: Bool = false
    @Published var dementiaSeverity: Severity = .none
    @Published var depressionSeverity: Severity = .none
    @Published var additionalDiagnoses: String = ""
    
    enum CodingKeys: CodingKey {
        case age, selectedDegree, selectedGender, hasVisionProblems, hasHearingProblems, dementiaSeverity, depressionSeverity, additionalDiagnoses
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Encode each property
        try container.encode(age, forKey: .age)
        try container.encode(selectedDegree.rawValue, forKey: .selectedDegree)
        try container.encode(selectedGender.rawValue, forKey: .selectedGender)
        try container.encode(hasVisionProblems, forKey: .hasVisionProblems)
        try container.encode(hasHearingProblems, forKey: .hasHearingProblems)
        try container.encode(dementiaSeverity.rawValue, forKey: .dementiaSeverity)
        try container.encode(depressionSeverity.rawValue, forKey: .depressionSeverity)
        try container.encode(additionalDiagnoses, forKey: .additionalDiagnoses)
    }
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
