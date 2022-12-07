# PercentageLayout

## Introduction
`PercentageLayout` is a library that provides the layout `PercentageHStack
` that can assign its subviews a percentage of its total width.

## Usage
The way the layout can determine how much space to take up is to use the `widthPercent(CGFloat)` function on the subviews of the `PercentageHStackLayout`.

Assigning values greater than or equal to 1 on the `widthPercent` will fill the remaining space and divide evenly with other subviews with no width percentage defined.


```swift
import PercentageLayout

var body: some View {
    PercentageHStackLayout(spacing: 10) {
        Color.red
            .widthPercent(0.1)

        Color.blue
            .widthPercent(0.2)

        Color.yellow

        Color.purple
    }
}
```

![Demo](https://raw.githubusercontent.com/ronzohan/PercentageLayout/main/Demo.png)