//
//  ResultView.swift
//  ChineseNameSugg
//
//  Created by ByteDance on 2025/2/14.
//

import SwiftUI

struct ResultView: View {
    let title: String
    let content: String
    let explanation: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\(title)：")
                .font(.headline)
            Text(content)
                .font(.title)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            
            Text("解释：")
                .font(.headline)
            Text(explanation)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
        }
    }
}
