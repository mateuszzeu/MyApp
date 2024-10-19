//
//  ValidationHelper.swift
//  Stronger
//
//  Created by Mateusz Żełudziewicz on 25/10/2024.
//

import Foundation

struct ValidationHelper {
    static func isValidEmail(_ email: String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: email)
    }
}
