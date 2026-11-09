import Foundation

struct Recipe: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let minutes: Int
    let servings: Int
    let symbol: String
    let ingredients: [String]
    let steps: [String]

    static let samples: [Recipe] = [
        Recipe(id: "lemon-pasta", title: "Lemon & basil pasta", subtitle: "Bright, silky, wonderfully simple.", minutes: 20, servings: 2, symbol: "leaf",
               ingredients: ["200 g spaghetti", "1 lemon, zest and juice", "30 g butter", "40 g Parmesan", "A handful of basil", "Sea salt & black pepper"],
               steps: ["Bring a large pan of salted water to a boil. Zest the lemon and pick the basil leaves.", "Cook the pasta for 8 minutes, until just al dente. Save a cup of the starchy cooking water before draining.", "Melt the butter gently. Add lemon zest and a splash of pasta water, then toss in the spaghetti.", "Fold in Parmesan and lemon juice. Finish with basil and black pepper, then serve warm."]),
        Recipe(id: "tomato-toast", title: "Tomato toast", subtitle: "A little summer, any time.", minutes: 10, servings: 2, symbol: "sun.max",
               ingredients: ["2 slices sourdough", "2 ripe tomatoes", "1 garlic clove", "2 tbsp olive oil", "Sea salt", "Fresh basil"],
               steps: ["Toast the sourdough until golden and crisp.", "Halve the garlic and rub it over the warm bread.", "Grate the tomatoes. Spoon over the toast and finish with olive oil, salt and basil."]),
        Recipe(id: "mushroom-rice", title: "Mushroom rice", subtitle: "Comfort in a single pan.", minutes: 30, servings: 2, symbol: "flame",
               ingredients: ["150 g rice", "200 g mushrooms", "1 shallot", "400 ml stock", "20 g butter", "Fresh parsley"],
               steps: ["Slice the mushrooms and finely chop the shallot.", "Soften the shallot in butter. Add mushrooms and cook until golden.", "Stir in rice and stock. Cover and simmer until tender.", "Rest for 5 minutes, then finish with parsley."])
    ]
}
