//
//  HomeView.swift
//  memtest-app
//
//  Created by Christopher Witzl on 13.05.24.
//

import SwiftUI

struct HomeView: View{
    
    var nextView: ((_ nextView: VisibleView) -> Void)
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Button(action: {
                    nextView(.skt)
                }) {
                    Text("SKT")
                        .font(.largeTitle)
                        .frame(width: 150, height: 150)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                Button(action: {
                    nextView(.vft)
                }) {
                    Text("VFT")
                        .font(.largeTitle)
                        .frame(width: 150, height: 150)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            HStack {
                Button(action: {
                    nextView(.bnt)
                }) {
                    Text("BNT")
                        .font(.largeTitle)
                        .frame(width: 150, height: 150)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                Button(action: {
                    nextView(.pdt)
                }) {
                    Text("PDT")
                        .font(.largeTitle)
                        .frame(width: 150, height: 150)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            Spacer()
        }
    }
}

#Preview {
    HomeView() { nextView in
        
    }
}
