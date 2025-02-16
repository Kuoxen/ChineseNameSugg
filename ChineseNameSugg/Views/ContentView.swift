//
//  ContentView.swift
//  ChineseNameSugg
//
//  Created by ByteDance on 2025/2/14.
//
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NameGeneratorView()
                .tabItem {
                    Label("起名", systemImage: "person.fill")
                }
            
            ZiGeneratorView()
                .tabItem {
                    Label("取字", systemImage: "character")
                }
            
            HaoGeneratorView()
                .tabItem {
                    Label("取号", systemImage: "doc.text")
                }
        }
    }
}
