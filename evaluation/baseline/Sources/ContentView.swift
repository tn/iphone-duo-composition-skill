import SwiftUI
import UIKit

private let ink = Color(red: 0.19, green: 0.25, blue: 0.19)
private let paper = Color(red: 0.97, green: 0.95, blue: 0.89)
private let saffron = Color(red: 0.91, green: 0.65, blue: 0.21)

struct ContentView: View {
    @State private var recipe = Recipe.samples[0]
    @State private var step = 1
    @State private var checked: Set<String> = []
    @State private var seconds = 480
    @State private var running = false
    @State private var folded = false
    @State private var ingredientsShown = false

    var body: some View {
        GeometryReader { geometry in
            let wide = geometry.size.width > 650
            VStack(spacing: 0) {
                header.padding(.horizontal, 26).padding(.vertical, 16)
                Rectangle().fill(ink.opacity(0.15)).frame(height: 1)
                if folded && wide {
                    VStack(spacing: 30) {
                        instruction(compact: true)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        HStack(alignment: .top, spacing: 32) {
                            ingredients.frame(maxWidth: .infinity)
                            timer.frame(maxWidth: .infinity)
                        }.frame(maxHeight: .infinity)
                    }.padding(28)
                } else if wide {
                    HStack(alignment: .top, spacing: 0) {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 32) {
                                recipeHeading
                                ingredients
                            }.padding(30)
                        }.frame(width: geometry.size.width * 0.42)
                        Rectangle().fill(ink.opacity(0.15)).frame(width: 1)
                        ScrollView {
                            VStack(spacing: 24) {
                                instruction(compact: false)
                                timer
                            }.padding(30)
                        }
                    }
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            recipeHeading
                            Picker("Recipe section", selection: $ingredientsShown) {
                                Text("Cook along").tag(false)
                                Text("Ingredients").tag(true)
                            }.pickerStyle(.segmented)
                            if ingredientsShown { ingredients } else {
                                instruction(compact: true)
                                timer
                            }
                        }.padding(24)
                    }
                }
            }
            .background(paper)
            .foregroundStyle(ink)
            .background(HingeReader(partiallyOpen: $folded))
        }
        .tint(ink)
        .preferredColorScheme(.light)
        .task(id: running) {
            guard running else { return }
            while !Task.isCancelled && running && seconds > 0 {
                do { try await Task.sleep(for: .seconds(1)) } catch { return }
                seconds -= 1
            }
            if seconds == 0 { running = false }
        }
    }

    private var header: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "sun.max.fill").foregroundStyle(saffron)
                Text("saffron").font(.system(size: 28, weight: .semibold, design: .serif))
            }
            Spacer()
            Menu {
                ForEach(Recipe.samples) { option in
                    Button(option.title, systemImage: option.symbol) {
                        recipe = option
                        step = 0
                        checked = []
                        running = false
                        seconds = 480
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "book.closed")
                    Text("Recipes")
                    Image(systemName: "chevron.down").font(.caption2.bold())
                }.font(.subheadline.weight(.medium))
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .background(.white.opacity(0.6), in: Capsule())
            }
        }
    }

    private var recipeHeading: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 7) {
                Image(systemName: recipe.symbol)
                Text("THE EVERYDAY TABLE").tracking(2)
            }.font(.system(size: 10, weight: .bold)).foregroundStyle(ink.opacity(0.6))
            Text(recipe.title)
                .font(.system(size: 38, weight: .regular, design: .serif))
                .fixedSize(horizontal: false, vertical: true)
            Text(recipe.subtitle).font(.subheadline).foregroundStyle(ink.opacity(0.65))
            HStack(spacing: 18) {
                Label("\(recipe.minutes) min", systemImage: "clock")
                Label("Serves \(recipe.servings)", systemImage: "person.2")
            }.font(.caption.weight(.medium)).padding(.top, 3)
        }.frame(maxWidth: .infinity, alignment: .leading)
    }

    private var ingredients: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Ingredients").font(.system(size: 25, design: .serif))
                Spacer()
                Text("\(checked.count)/\(recipe.ingredients.count)")
                    .font(.caption.monospacedDigit()).foregroundStyle(ink.opacity(0.5))
            }
            VStack(spacing: 0) {
                ForEach(recipe.ingredients, id: \.self) { item in
                    Button {
                        if checked.contains(item) { checked.remove(item) } else { checked.insert(item) }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: checked.contains(item) ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 22, weight: .light))
                                .foregroundStyle(checked.contains(item) ? ink : ink.opacity(0.3))
                            Text(item).font(.system(size: 15))
                                .strikethrough(checked.contains(item))
                                .foregroundStyle(ink.opacity(checked.contains(item) ? 0.4 : 1))
                            Spacer(minLength: 0)
                        }.padding(.vertical, 13).contentShape(Rectangle())
                    }.buttonStyle(.plain)
                    Rectangle().fill(ink.opacity(0.1)).frame(height: 1)
                }
            }
        }
    }

    private func instruction(compact: Bool) -> some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack {
                Text("LET’S GET COOKING").tracking(2).font(.system(size: 10, weight: .bold))
                Spacer()
                Text("\(step + 1) OF \(recipe.steps.count)").font(.system(size: 10, weight: .bold)).tracking(1)
            }.foregroundStyle(ink.opacity(0.6))
            HStack(spacing: 6) {
                ForEach(recipe.steps.indices, id: \.self) { index in
                    Capsule().fill(index <= step ? saffron : ink.opacity(0.1)).frame(height: 4)
                }
            }
            HStack(alignment: .firstTextBaseline, spacing: 16) {
                Text(String(format: "%02d", step + 1))
                    .font(.system(size: compact ? 46 : 64, weight: .regular, design: .serif))
                    .foregroundStyle(saffron)
                Text(stepTitle).font(.system(size: compact ? 28 : 34, design: .serif))
            }
            Text(recipe.steps[step])
                .font(.system(size: compact ? 20 : 23, weight: .regular, design: .serif))
                .lineSpacing(7)
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                Button { step = max(0, step - 1) } label: {
                    Label("Back", systemImage: "arrow.left").font(.subheadline.weight(.medium))
                }.disabled(step == 0).opacity(step == 0 ? 0.3 : 1)
                Spacer()
                Button { if step < recipe.steps.count - 1 { step += 1 } } label: {
                    HStack {
                        Text(step == recipe.steps.count - 1 ? "Bon appétit" : "Next step")
                        Image(systemName: step == recipe.steps.count - 1 ? "checkmark" : "arrow.right")
                    }.font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 20).padding(.vertical, 14)
                        .background(ink, in: Capsule()).foregroundStyle(paper)
                }.disabled(step == recipe.steps.count - 1)
            }.padding(.top, 6)
        }
        .padding(compact ? 22 : 28)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.55), in: RoundedRectangle(cornerRadius: 24))
    }

    private var stepTitle: String {
        if recipe.id == "lemon-pasta" { return ["A little prep", "Into the pot", "Make it silky", "The finishing touch"][step] }
        return "Step \(step + 1)"
    }

    private var timer: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("KITCHEN TIMER", systemImage: "timer").font(.system(size: 10, weight: .bold)).tracking(1.5)
                Spacer()
                Text(seconds == 0 ? "DONE" : running ? "RUNNING" : "PAUSED")
                    .font(.system(size: 9, weight: .bold)).tracking(1)
                    .padding(.horizontal, 9).padding(.vertical, 5)
                    .background(paper.opacity(0.12), in: Capsule())
            }
            Text(String(format: "%02d:%02d", seconds / 60, seconds % 60))
                .font(.system(size: 64, weight: .light, design: .rounded)).monospacedDigit()
                .frame(maxWidth: .infinity)
            HStack(spacing: 12) {
                Button { running = false; seconds = 480 } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .frame(width: 46, height: 46)
                        .background(paper.opacity(0.12), in: Circle())
                }
                Button {
                    if seconds == 0 { seconds = 480 }
                    running.toggle()
                } label: {
                    Label(running ? "Pause timer" : "Start timer", systemImage: running ? "pause.fill" : "play.fill")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity).padding(.vertical, 15)
                        .background(saffron, in: Capsule()).foregroundStyle(ink)
                }
            }
        }.padding(24).foregroundStyle(paper)
            .background(ink, in: RoundedRectangle(cornerRadius: 24))
    }
}

private struct HingeReader: UIViewRepresentable {
    @Binding var partiallyOpen: Bool
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        if #available(iOS 27.1, *) {
            view.addInteraction(UIHingeInteraction { _, update in
                let value = update.hinge?.status == .partiallyOpen
                Task { @MainActor in partiallyOpen = value }
            })
        }
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {}
}
