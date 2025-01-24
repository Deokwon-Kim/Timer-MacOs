//
//  ContentView.swift
//  Timer
//
//  Created by 김덕원 on 1/24/25.
//

import SwiftUI
import Combine
import AVFoundation

struct ContentView: View {
    // 타이머 설정 값 (초 단위)
    @State private var totalTimes: Int = 60
    @State private var timeRemaining: Int = 60
    @State private var isRunning: Bool = false
    @State private var timer: AnyCancellable?
    @State private var audioPlayer: AVAudioPlayer?
    @State private var progress: Double = 0.0
    
    var body: some View {
        VStack {
            CircularProgressBar(progress: progress)
                .frame(width: 150, height:150)
                .padding()
            HStack {
                // 시작/정지 버튼
                
                Button(action: {
                    if !isRunning {
                        startTimer()
                    } else {
                        stopTimer()
                    }
                }) {
                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .padding()
                }
                .padding()
                
                // 리셋 버튼
                Button(action: {
                    stopTimer()
                    timeRemaining = 60
                }) {
                    Image(systemName: "arrow.clockwise")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .padding()
                }
            }
        }
        .padding()
        .frame(width: 400)
        .background(.black)
    }
    
    private func CircularProgressBar(progress: Double) -> some View {
        ZStack {
            // 배경 원
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 10)
            
            // 진행 원
            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(timeRemaining <= 5 ? .red : .orange, style: StrokeStyle(lineWidth: 10, lineCap: .round)) // 5초 남은경우 프로그레스바 색 빨간색으로 변경
                .rotationEffect(.degrees(-90))
                .animation(.linear, value: progress)
            
            // 시간을 MM:SS 형식으로 표시
            Text("\(String(format: "%02d", timeRemaining / 60)):\(String(format: "%02d", timeRemaining % 60))")
                .font(.system(size: 50, weight: .bold))
                .foregroundStyle(timeRemaining <= 5 ? .red : .white)// 5초 남았을시 텍스트 빨간색으로 변경
                .onTapGesture {
                    // 타이머 설정 순환: 1분 -> 5분 -> 10분 -> 1분
                    if !isRunning { // 타이머가 실행중이 아닐 때만 변경 가능
                        if totalTimes == 60 {
                            totalTimes = 300 // 5분
                        } else if totalTimes == 300 {
                            totalTimes = 600 // 10분
                        } else {
                            totalTimes = 60 // 1분
                        }
                        timeRemaining = totalTimes // 변경된 전체시간으로 남은시간 초기화
                        self.progress = 1.0 // 프로그레스바 초기화
                    }
                }
        }
    }
    
    private func startTimer() {
        guard !isRunning, timeRemaining > 0 else { return }
        
        isRunning = true
        timer = Timer.publish(every: 1, on: .main, in: .common) // 1초 간격으로 수정
            .autoconnect()
            .sink { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                    
                    progress =  Double(timeRemaining) / Double(totalTimes)
                }
                if timeRemaining == 0 {
                    stopTimer()
                    playCustomSound()
                }
            }
    }
    
    private func stopTimer() {
        isRunning = false
        timer?.cancel()
        timer = nil
    }
    
    func playCustomSound() {
        if let sound = NSSound(named: "timersound") { // 사운드 파일 이름 (확장자 제외)
            sound.play()
        } else {
            print("사운드 파일을 찾을 수 없습니다.")
        }
    }

}

#Preview {
    ContentView()
}
