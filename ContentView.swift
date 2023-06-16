//
//  ContentView.swift
//  EditCopy
//
//  Created by 平山奈々海 on 2023/06/13.
//

import SwiftUI

struct Block : Identifiable,Codable {
    var id = UUID()
    var title : String
    var text : String
}

struct ContentView: View {
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemMint
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    /*
     @State var titleBlock :[String] = []
     @State var textBlock :[String] = []
     
     @State var Block = [[""],[""]]
     */
    @State var newItemTitle = ""
    @State var newItemText = ""
    
    @State var iteme = "onakagasuita"
    
    
    @State var blocks: [Block] = UserDefaults.standard.getBlocks(forKey: "blocks")
    
    @State var isEditing: Bool = false // 編集モードの追加
    
    @State var isTitleEmpty = false
    
    @FocusState var focus:Bool
    
    
    var body: some View {
        NavigationStack {
            VStack {
                
                ScrollView{
                    ForEach(blocks) { block in
                        VStack{
                            if isEditing { // 編集モードの場合にのみテキストフィールドを表示
                                TextField("タイトル", text: $blocks[getIndex(for: block)].title, axis: .vertical)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding([.leading, .trailing])
                                TextField("内容", text: $blocks[getIndex(for: block)].text, axis: .vertical).textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding([.leading, .trailing])
                            }
                            else {
                                HStack{
                                    Text(block.title)
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                        .padding(.top)
                                        .padding([.leading, .trailing])
                                    Spacer()
                                    Button {
                                        UIPasteboard.general.string = block.text
                                        
                                    } label: {
                                        Image(systemName: "doc.on.doc")
                                            .padding(.top)
                                            .padding([.leading, .trailing])
                                        
                                    }

                                }
                                
                                Spacer()
                                Text(block.text)
                                    .lineLimit(4)
                                    .padding([.leading, .trailing])
                                Spacer()
                            }
                            if isEditing { // 編集モードの場合にのみ削除ボタンを表示
                                Button {
                                    deleteBlock(block)
                                } label: {
                                    Text("削除")
                                        .frame(width:80,height:30)
                                        
                                        .foregroundColor(.white)
                                        .background(Color.mint)
                                        .cornerRadius(8)
                                }
                            }
                            
                        }
                        .frame(width:300, height:200)
                        .background(.white)
                        .cornerRadius(10)
                        .clipped()
                        .shadow(color: .gray.opacity(0.7), radius: 5)
                        .onTapGesture {
                                   self.focus = false
                               }
                        
                        
                        .padding()
                    }
                    
                    .padding()
                }
                    TextField("タイトル", text: $newItemTitle, axis: .vertical)
                        .focused(self.$focus)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding([.leading, .trailing])
                    TextField("内容", text: $newItemText, axis: .vertical)
                        .focused(self.$focus)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding([.leading, .trailing])

                
                
                HStack {
                    Button {
                        if(newItemText.isEmpty || newItemTitle.isEmpty){
                            isTitleEmpty = true
                        }
                        else{
                            blocks.append(Block(title: newItemTitle, text: newItemText))
                            newItemText = ""
                            newItemTitle = ""
                            self.focus = false
                            UserDefaults.standard.setBlocks(blocks, forKey: "blocks")
                        }
                    } label: {
                            Text("追加する")
                            .frame(width:100,height:40)
                            
                            .foregroundColor(.white)
                            .background(Color.mint)
                            .cornerRadius(10)
                    }
                    .padding()
                    .alert(isPresented: $isTitleEmpty) {
                        Alert(title: Text("タイトルと内容を両方入力してね"),dismissButton: .default(Text("了解"),
                                                                                     action: {self.isTitleEmpty = false}))
                    }
                    
                   
                }
                
            }
            .navigationTitle("コピペ文章保存アプリ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing){
                    Button {
                        isEditing.toggle() // 編集モードのトグル
                        
                    } label: {
                        Text(isEditing ? "完了" : "編集")
                            .foregroundColor(.white)
                    }

                }
            }

            
        }
        
        
    }
    // ブロックのインデックスを取得するヘルパーメソッド
    private func getIndex(for block: Block) -> Int {
        if let index = blocks.firstIndex(where: { $0.id == block.id }) {
            return index
        }
        return 0}
    
    private func deleteBlock(_ block: Block) {
        if let index = blocks.firstIndex(where: { $0.id == block.id }) {
            blocks.remove(at: index)
            UserDefaults.standard.setBlocks(blocks, forKey: "blocks")
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension UserDefaults {
    func setBlocks(_ value: [Block], forKey key: String) {
        if let encoded = try? JSONEncoder().encode(value) {
            set(encoded, forKey: key)
        }
    }
    
    func getBlocks(forKey key: String) -> [Block] {
        if let data = data(forKey: key),
           let blocks = try? JSONDecoder().decode([Block].self, from: data) {
            return blocks
        }
        return []
    }
}

struct AnimationButtonStyle : ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding()
            .background(configuration.isPressed ? Color.red : Color.blue )
            .scaleEffect(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeOut(duration: 1.0), value: configuration.isPressed)
    }
}
