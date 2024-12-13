import SwiftUI

struct UserProfileView: View {
    var body: some View {
        NavigationView {
            ZStack {
                // 背景图片，覆盖 NavigationBar 和 StatusBar
                Image("header") // 替换为实际图片名称
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.top)

                VStack {
                    // Header 部分
                    VStack {
                        HStack {
                            Image(systemName: "person.crop.circle.fill") // 用户头像
                                .resizable()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .padding(.trailing, 10)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("会飞的鱼")
                                    .font(.headline)
                                    .foregroundColor(.white)

                                HStack {
                                    Image(systemName: "crown.fill")
                                        .foregroundColor(.yellow)
                                    Text("2024/11/27到期")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }

                            Spacer()
                        }
                        .padding()
                        .background(Color.white.opacity(0.2)) // 半透明背景
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }
                    .padding(.top, 80) // 下移以避开状态栏和导航栏

                    // 列表部分
                    List {
                        Section {
                            MenuRow(icon: "star.fill", title: "给我们评分")
                            MenuRow(icon: "square.and.arrow.up", title: "分享给好友")
                            MenuRow(icon: "headphones", title: "联系客服")
                            MenuRow(icon: "gearshape.fill", title: "设置")
                        }

                        Section(header: Text("作品").font(.headline).foregroundColor(.purple)) {
                            VStack {
                                Image(systemName: "camera.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.gray)
                                Text("暂无作品")
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical)
                        }
                    }
                    .listStyle(InsetGroupedListStyle()) // 列表样式
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("我的页面")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// 可复用的 MenuRow 组件
struct MenuRow: View {
    let icon: String
    let title: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(.purple)
                .padding(.trailing, 10)

            Text(title)
                .font(.body)
                .foregroundColor(.black)

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 10)
    }
}

struct UserProfileWithListView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView()
    }
}
