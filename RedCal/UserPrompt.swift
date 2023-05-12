//
//  UserPrompt.swift
//  RedCal
//
//  Created by Carissa Farry Hilmi Az Zahra on 08/05/23.
//

import SwiftUI

struct Prompt {
    let question: String
    let answerInputType: AnswerInputType
    let options: [String]?
}

struct Answer {
    var promptID: Int
    var answer: AnswerType
}

enum AnswerInputType {
    case date
    case number
}

protocol AnswerType {}

struct DateAnswer: AnswerType {
    let date: Date
}

struct NumericAnswer: AnswerType {
    let number: Int
}

let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height


struct UserPrompt: View {
    @State private var currentCardIndex = 0
    
    @State var prompts: [Prompt] = [
        Prompt(
            question: "When is your last period date?",
            answerInputType: .date,
            options: nil
        ),
        Prompt(
            question: "How much your usual period length?",
            answerInputType: .number,
            options: nil
        ),
        Prompt(
            question: "How much your usual period cycle length?",
            answerInputType: .number,
            options: nil
        ),
    ]
    
    @State var answers: [Answer] = []
    
    var body: some View {
        VStack {
            TabView(selection: $currentCardIndex) {
                ForEach((prompts.indices), id: \.self) { index in
                  PromptCard(prompts: $prompts, currentCardIndex: $currentCardIndex)
                }
                
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        }
        .frame(height: screenHeight * 0.7)
    }
    
    func slideCardLeft() {
        withAnimation {
            currentCardIndex -= 1
        }
    }
    
    func slideCardRight() {
        withAnimation {
            currentCardIndex += 1
        }
    }
}


struct PromptCard: View {
    @Binding var prompts: [Prompt]
    @Binding var currentCardIndex: Int
    @EnvironmentObject var answerManager: AnswerManager
    
    @State var dateAnswer = Date.now
    @State var numberAnswer = -1
    
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
                .cornerRadius(30)
                .padding(.vertical, screenWidth * 0.05)
                .frame(width:screenWidth * 0.8, height: screenHeight * 0.7)
                .shadow(color: Color.black.opacity(0.2), radius: 7, x: 0, y: 0)
            
            VStack {
                Text(prompts[currentCardIndex].question)
                    .foregroundColor(.black)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, screenWidth * 0.15)
                
                // Conditional picker and selection for data saving
                switch prompts[currentCardIndex].answerInputType {
                    case .date:
                        DatePicker("", selection: $dateAnswer, displayedComponents: .date)
                            .datePickerStyle(.wheel)
                            .frame(maxHeight: 400)
                            .labelsHidden()
                        
                    case .number:
                        Picker("", selection: $numberAnswer) {
                            ForEach(1...14, id: \.self) { number in
                                Text("\(number)")
                            }
                        }
                        .frame(maxHeight: 400)
                            .pickerStyle(.wheel)
                            .labelsHidden()
                            .padding(.horizontal, screenWidth * 0.1)
                }
                
                Button(action: {
                    let answer: Answer
                    
                    switch prompts[currentCardIndex].answerInputType {
                        case .date:
                            answer = Answer(promptID: currentCardIndex, answer: DateAnswer(date: dateAnswer))
                        case .number:
                            answer = Answer(promptID: currentCardIndex, answer: NumericAnswer(number: numberAnswer))
                    }
                    
                    saveOrUpdateAnswer(answer: answer)

                    if currentCardIndex < (prompts.count - 1) {
                        currentCardIndex += 1
                    }
                    
                    print(answerManager.answers)
                }) {
                    if currentCardIndex < (prompts.count - 1) {
                        ZStack {
                            Rectangle ()
                                .frame(width: screenWidth * 0.65, height: screenHeight * 0.05)
                                .cornerRadius(10)
                            
                            Text("Save")
                                .foregroundColor(.white)
                        }
                    } else {
                        NavigationLink(
                            destination: MainView()
                                .navigationBarBackButtonHidden(true)
                        ) {
                            ZStack {
                                Rectangle ()
                                    .frame(width: screenWidth * 0.65, height: screenHeight * 0.05)
                                    .cornerRadius(10)
                                    .foregroundColor(.green)
                                
                                Text("Next")
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func saveOrUpdateAnswer(answer: Answer) {
        let answers = answerManager.answers
        
        if let index = answers.firstIndex(where: { $0.promptID == answer.promptID }) {
            answerManager.updateAnswer(at: index, with: answer)
        } else {
            answerManager.addAnswer(answer)
        }
    }
}

struct UserPrompt_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var answerManager = AnswerManager()
        
        UserPrompt()
            .environmentObject(answerManager)
    }
}
