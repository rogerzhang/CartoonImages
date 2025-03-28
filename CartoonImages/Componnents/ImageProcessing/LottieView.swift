//
//  LottieView.swift
//  CartoonImages
//
//  Created by roger on 2025/3/28.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let name: String
    let loopMode: LottieLoopMode
    let animationSpeed: CGFloat
    
    func makeUIView(context: Context) -> LottieAnimationView {
        let animationView = LottieAnimationView(name: name)
        animationView.loopMode = loopMode
        animationView.animationSpeed = animationSpeed
        animationView.play()
        animationView.contentMode = .scaleAspectFit
        animationView.backgroundColor = .clear
        return animationView
    }
    
    func updateUIView(_ uiView: LottieAnimationView, context: Context) {}
}

struct RobustLottieView: UIViewRepresentable {
    let name: String
    let loopMode: LottieLoopMode
    let animationSpeed: CGFloat
    var contentMode: UIView.ContentMode = .scaleAspectFit
    
    func makeUIView(context: Context) -> LottieAnimationView {
        let animationView = LottieAnimationView()
        animationView.contentMode = contentMode
        animationView.backgroundColor = .clear
        
        // 加载动画
        loadAnimation(in: animationView)
        
        return animationView
    }
    
    func updateUIView(_ uiView: LottieAnimationView, context: Context) {
        // 防止重复加载
        if uiView.animation == nil {
            loadAnimation(in: uiView)
        }
    }
    
    private func loadAnimation(in view: LottieAnimationView) {
        // 方式1：从主Bundle加载
        if let animation = LottieAnimation.named(name) {
            view.animation = animation
            view.loopMode = loopMode
            view.animationSpeed = animationSpeed
            view.play()
            return
        }
        
        // 方式2：尝试从文件路径加载
        if let path = Bundle.main.path(forResource: name, ofType: "json") {
            view.animation = LottieAnimation.filepath(path)
            view.loopMode = loopMode
            view.animationSpeed = animationSpeed
            view.play()
            return
        }
        
        print("⚠️ 无法加载Lottie动画: \(name)")
    }
}

struct SafeLottieView: UIViewRepresentable {
    let name: String
    let loopMode: LottieLoopMode
    let animationSpeed: CGFloat
    
    func makeUIView(context: Context) -> UIView {
        // 容器视图
        let container = UIView()
        container.backgroundColor = .clear
        
        // Lottie视图
        let animationView = LottieAnimationView(name: name)
        animationView.loopMode = loopMode
        animationView.animationSpeed = animationSpeed
        animationView.contentMode = .scaleAspectFill  // 关键设置
        animationView.backgroundColor = .clear
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(animationView)
        
        // 约束设置
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            animationView.widthAnchor.constraint(equalTo: container.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: container.heightAnchor)
        ])
        
        animationView.play()
        
        return container
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct ProgressLottieView: UIViewRepresentable {
    let name: String
    @Binding var progress: CGFloat // 0.0 ~ 1.0
    var loopMode: LottieLoopMode = .playOnce
    var animationSpeed: CGFloat = 1.0
    
    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        
        // 创建Lottie视图
        let animationView = LottieAnimationView(name: name)
        animationView.loopMode = loopMode
        animationView.animationSpeed = animationSpeed
        animationView.contentMode = .scaleAspectFit
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        // 存储动画视图以便更新
        container.addSubview(animationView)
        context.coordinator.animationView = animationView
        
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            animationView.widthAnchor.constraint(equalTo: container.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: container.heightAnchor)
        ])
        
        // 初始进度设置
        updateProgress(animationView: animationView, progress: progress)
        
        return container
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let animationView = context.coordinator.animationView else { return }
        updateProgress(animationView: animationView, progress: progress)
    }
    
    private func updateProgress(animationView: LottieAnimationView, progress: CGFloat) {
        // 确保进度在0~1范围内
        let clampedProgress = max(0, min(1, progress))
        
        // 设置当前进度（自动处理播放状态）
        animationView.currentProgress = clampedProgress
        
        // 如果进度为1且是单次播放模式，确保动画完成
        if clampedProgress >= 1.0 && loopMode == .playOnce {
            animationView.play(toProgress: 1.0)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var animationView: LottieAnimationView?
    }
}

import Combine

struct SmoothLottieProgressView: UIViewRepresentable {
    // MARK: - 配置参数
    let name: String
    @Binding var progress: CGFloat // 0.0 ~ 1.0
    var loopMode: LottieLoopMode = .playOnce
    var animationSpeed: CGFloat = 1.0
    var transitionDuration: Double = 0.5 // 过渡动画时长
    var dampingRatio: CGFloat = 0.6 // 弹簧阻尼系数 (0~1)
    
    // MARK: - UIViewRepresentable 协议实现
    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        
        // 创建Lottie视图
        let animationView = LottieAnimationView(name: name)
        animationView.loopMode = loopMode
        animationView.animationSpeed = animationSpeed
        animationView.contentMode = .scaleAspectFit
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        // 存储动画视图以便更新
        container.addSubview(animationView)
        context.coordinator.animationView = animationView
        
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            animationView.widthAnchor.constraint(equalTo: container.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: container.heightAnchor)
        ])
        
        // 初始进度设置
        updateProgress(animationView: animationView, progress: progress, animated: false)
        
        return container
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let animationView = context.coordinator.animationView else { return }
        
        // 使用节流避免频繁更新
        context.coordinator.throttledProgress = progress
        context.coordinator.scheduleAnimationUpdate()
    }
    
    // MARK: - 进度更新逻辑
    private func updateProgress(animationView: LottieAnimationView, progress: CGFloat, animated: Bool) {
        let clampedProgress = max(0, min(1, progress))
        
        if animated {
            // 使用弹簧动画实现平滑过渡
            UIView.animate(
                withDuration: transitionDuration,
                delay: 0,
                usingSpringWithDamping: dampingRatio,
                initialSpringVelocity: 0,
                options: [.beginFromCurrentState, .allowUserInteraction, .curveEaseOut],
                animations: {
                    animationView.currentProgress = clampedProgress
                },
                completion: { _ in
                    if clampedProgress >= 1.0 && self.loopMode == .playOnce {
                        animationView.play(toProgress: 1.0)
                    }
                }
            )
        } else {
            // 无动画直接设置
            animationView.currentProgress = clampedProgress
        }
    }
    
    // MARK: - Coordinator 实现
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        let parent: SmoothLottieProgressView
        var animationView: LottieAnimationView?
        var throttledProgress: CGFloat = 0
        var updateScheduled = false
        
        init(_ parent: SmoothLottieProgressView) {
            self.parent = parent
        }
        
        // 节流更新机制
        func scheduleAnimationUpdate() {
            guard !updateScheduled else { return }
            
            updateScheduled = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                guard let self = self else { return }
                self.updateScheduled = false
                
                if let animationView = self.animationView {
                    self.parent.updateProgress(
                        animationView: animationView,
                        progress: self.throttledProgress,
                        animated: true
                    )
                }
            }
        }
    }
}

// MARK: - 使用示例
struct SmoothLottieProgressDemo: View {
    @State private var progress: CGFloat = 0.0
    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 30) {
            // 平滑进度动画
            SmoothLottieProgressView(
                name: "progress_animation", // 你的Lottie文件名
                progress: $progress,
                loopMode: .playOnce,
                animationSpeed: 1.0,
                transitionDuration: 0.8,
                dampingRatio: 0.7
            )
            .frame(width: 200, height: 200)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            
            // 进度显示
            Text("\(Int(progress * 100))%")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .monospacedDigit()
            
            // 控制按钮
            HStack(spacing: 20) {
                Button(action: { progress = max(0, progress - 0.2) }) {
                    Text("-20%")
                        .frame(width: 80)
                }
                
                Button(action: { progress = min(1, progress + 0.2) }) {
                    Text("+20%")
                        .frame(width: 80)
                }
            }
            .buttonStyle(.borderedProminent)
            
            // 重置按钮
            Button("Reset") {
                withAnimation(.spring()) {
                    progress = 0
                }
            }
        }
        .padding()
        .onReceive(timer) { _ in
            // 模拟自动进度更新
            if progress < 1.0 {
                progress += 0.05
            }
        }
    }
}
