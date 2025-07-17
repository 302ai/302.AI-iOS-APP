//
//  PromptsListView.swift
//  GPTalks
//
//  Created by Adswave on 2025/4/21.
//

import SwiftUI
import AlertToast

struct Agent: Codable, Identifiable {
    let id: String
    let name: String
    let emoji: String
    let group: [String]
    let enGroup: [String]
    let prompt: String
    let enPrompt: String
    let description: String
    
    private enum CodingKeys: String, CodingKey {
        case id, name, emoji, group
        case enGroup = "en_group"
        case prompt, enPrompt = "en_prompt", description
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        emoji = try container.decodeIfPresent(String.self, forKey: .emoji) ?? "❓" // 默认值
        group = try container.decode([String].self, forKey: .group)
        enGroup = try container.decode([String].self, forKey: .enGroup)
        prompt = try container.decode(String.self, forKey: .prompt)
        enPrompt = try container.decode(String.self, forKey: .enPrompt)
        description = try container.decode(String.self, forKey: .description)
    }
}


class AgentDataService {
    static func loadAgents() -> [Agent] {
        guard let url = Bundle.main.url(forResource: "agents", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return []
        }
        
        
        do {
            return try JSONDecoder().decode([Agent].self, from: data)
        } catch {
            print("Error decoding JSON: \(error)")
            return []
        }
    }
}


struct PromptsListView: View {
    
    @Environment(\.dismiss) var dismiss
    let agents = AgentDataService.loadAgents()
    @Bindable var viewModel: DialogueViewModel
    
    @State private var selectedGroup: String? = nil
    
    @State private var showGroupMenu = false
    
    @State private var selectedAgent: Agent? = nil  // 新增：跟踪选中的Agent
    @State var isShowToast = false
    
    // 获取所有不重复的 group
    var allGroups: [String] {
        let groups = Set(agents.flatMap { $0.group })
        return Array(groups).sorted()
    }
    
    // 根据选择的 group 过滤 agents
    var filteredAgents: [Agent] {
        if let group = selectedGroup {
            return agents.filter { $0.group.contains(group) }
        } else {
            return agents
        }
    }
    
    var body: some View {
        ZStack{
            
            VStack(alignment: .leading, spacing: 10) {
                 
                Text("提示词")
                    .foregroundStyle(.primary)
                    .font(.headline)
                
                Button {
                    showGroupMenu = true
                } label: {
                    HStack{
                        Image(systemName: "list.triangle")
                        Text(selectedGroup ?? "全部")
                    }
                    
                }
                List {
                    ForEach(filteredAgents) { agent in
                        CardView(agent: agent)
                            .onTapGesture {
                                
                                selectedAgent = agent
                                print("Selected Agent: \(agent)")  // 打印选中的Agent
                                
                                // 如果需要更详细的打印：
                                print("""
                                                    Selected Agent Details:
                                                    ID: \(agent.id)
                                                    Name: \(agent.name)
                                                    Emoji: \(agent.emoji)
                                                    Groups: \(agent.group.joined(separator: ", "))
                                                    Description: \(agent.description)
                                                    """)
                                
                                
                                
//                                isShowToast = true
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                                    isShowToast = false
//                                }
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
//                                    dismiss()
//                                }
                                
                                //提示词  敬请期待
                                dismiss()
                                viewModel.addDialogue(conversations: [Conversation(role: .user, content: agent.prompt,arguments: "预设提示词",atModelName: "",contentS: "")],title: agent.name,promptModel: "deepseek-chat")
                                 
                            }
                    }
                }
                
//                .toast(isPresenting: $isShowToast){
//                    AlertToast(displayMode: .alert, type: .regular, title: "敬请期待")
//                }
                
            }.padding()
            
 
            
            // View2 弹出层
            if showGroupMenu {
                
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            showGroupMenu = false
                        }
                    }
                
                GroupMenuView(
                    groups: allGroups,
                    selectedGroup: $selectedGroup,
                    isShowing: $showGroupMenu
                )
                .transition(.move(edge: .leading))
                .zIndex(1)
            }
            
        }
        .animation(.easeInOut, value: showGroupMenu)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading) // 整体左上对齐
        
            
    }
}



// 更新卡片子视图（添加图标显示）
struct CardView: View {
    let agent: Agent
    
    
    // 渐变颜色生成（中间深色向两侧变浅）
    private func gradientColors(for base: Color) -> [Color] {
        return [
            base.opacity(0.2), // 左侧浅色
            base.opacity(0.5),            // 中间深色
            base.opacity(0.2)  // 右侧浅色
        ]
    }
    
    // 随机颜色生成器
    private func randomColor() -> Color {
        let colors: [Color] = [.blue, .green, .orange, .pink, .purple, .red, .teal, .yellow]
        return colors.randomElement() ?? .blue
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: gradientColors(for: randomColor())),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 60)
                .frame(maxWidth: .infinity)
                
//                Image(systemName: "photo.artframe")
//                    .font(.system(size: 28))
//                    .foregroundColor(.white)
                Text(agent.emoji)
            }
            .clipShape(RoundedCorner(radius: 12, corners: [.topLeft, .topRight]))
            
            
            HStack {
                Text(agent.name)
                    .font(.system(size: 18, weight: .bold))
                Spacer()
            }
            
            Text(agent.description)
                .font(.subheadline)
                .foregroundColor(.gray)
            
//            Text(agent.content)
//                .font(.body)
//                .padding(.vertical, 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    
  
    
    
    // 圆角自定义（用于只给顶部加圆角）
    struct RoundedCorner: Shape {
        var radius: CGFloat = .infinity
        var corners: UIRectCorner = .allCorners
        
        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(
                roundedRect: rect,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius, height: radius)
            )
            return Path(path.cgPath)
        }
    }

    
}


struct AgentRow: View {
    let agent: Agent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(agent.emoji)  // 提供默认表情
                Text(agent.name)
                    .font(.headline)
            }
            
            Text(agent.description.components(separatedBy: "\r\n").first ?? "")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("分组: \(agent.group.joined(separator: ", "))")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
}



struct GroupMenuView: View {
    let groups: [String]
    @Binding var selectedGroup: String?
    @Binding var isShowing: Bool
    
    var body: some View {
        GeometryReader { geometry in
            List {
                Section {
                    Button(action: {
                        selectedGroup = nil
                        isShowing = false
                    }) {
                        HStack {
                            Text("全部")
                            Spacer()
                            if selectedGroup == nil {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.purple)
                            }
                        }
                        .padding(12)
                        .background(
                            selectedGroup == nil ? Color.purple.opacity(0.1) : Color.clear // 浅紫色背景
                        )
                        .cornerRadius(6)
                    }
                }
                
                Section("分组") {
                    ForEach(groups, id: \.self) { group in
                        Button(action: {
                            selectedGroup = group
                            isShowing = false
                        }) {
                            HStack {
                                Text(group)
                                Spacer()
                                if selectedGroup == group {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.purple)
                                }
                            }
                            .padding(12)
                            .background(
                                selectedGroup == group ? Color.purple.opacity(0.1) : Color.clear // 浅紫色背景
                            )
                            .cornerRadius(6)
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            .frame(width: geometry.size.width * 0.7) // 内容视图 (3/4 屏幕宽度)
            .background(Color.white)
            
            //        .listStyle(.sidebar)
            //        .frame(maxHeight: .infinity)
            //        .background(Color(.systemBackground))
            //        .shadow(radius: 5)
            
        }
    }
}



