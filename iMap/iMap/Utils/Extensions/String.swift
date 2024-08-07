//
//  String.swift
//  iMap
//
//  Created by Tung on 01/08/2024.
//

import Foundation

extension String {
    var formatPhoneNumber: String {
        self.replacingOccurrences(of: " ", with: " ")
            .replacingOccurrences(of: "+", with: " ")
            .replacingOccurrences(of: "(", with: " ")
            .replacingOccurrences(of: ")", with: " ")
            .replacingOccurrences(of: "-", with: " ")
    }
}
