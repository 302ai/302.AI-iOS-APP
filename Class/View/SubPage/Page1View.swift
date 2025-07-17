import SwiftUI

struct Page1View: View {
    @State private var showView2 = false
    
    var body: some View {
        ZStack {
            // 主视图内容
            VStack {
                Text("这是Page1视图")
                    .font(.title)
                    .padding()
                
                Button("显示View2") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showView2 = true
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding()
                
                Spacer()
            }
            
            // 蒙版和View2
            if showView2 {
                // 半透明蒙版
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            showView2 = false
                        }
                    }
                
                // View2
                View2(isPresented: $showView2)
                    .frame(width: 400, height: 500)
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 10)
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(1)
            }
        }
    }
}

struct View2: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            Text("这是View2")
                .font(.title)
                .padding()
            
            Spacer()
            
            Button("关闭View2") {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isPresented = false
                }
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .padding()
    }
}

// 预览
struct Page1View_Previews: PreviewProvider {
    static var previews: some View {
        Page1View()
    }
}
