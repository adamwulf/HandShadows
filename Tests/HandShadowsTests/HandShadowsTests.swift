@testable import HandShadows
import XCTest

final class HandShadowsTests: XCTestCase {
    func testExample() throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
    }

    func testGenerateHandShadowImages() throws {
        // Directory to save shadow images
        let outputDir = "~/Downloads/shadows/"

        // Create directory if it doesn't exist
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: outputDir) {
            try fileManager.createDirectory(atPath: outputDir, withIntermediateDirectories: true)
        }

        // Generate shadow images for both left and right hand types
        generateShadowImages(for: .leftHand, outputDir: outputDir)
        generateShadowImages(for: .rightHand, outputDir: outputDir)
    }

    private func generateShadowImages(for handType: HandType, outputDir: String) {
        // Canvas size for rendering shadows
        let size = CGSize(width: 2080, height: 2080)

        // Generate pointer finger shadow
        generatePointerFingerShadow(for: handType, size: size, outputDir: outputDir)

        // Generate two-finger pan shadow
        generateTwoFingerPanShadow(for: handType, size: size, outputDir: outputDir)

        // Generate pinch shadow
        generatePinchShadow(for: handType, size: size, outputDir: outputDir)
    }

    private func generatePointerFingerShadow(for handType: HandType, size: CGSize, outputDir: String) {
        let handShadow = HandShadow(for: handType)

        // Set up a point in the middle of the canvas
        let point = CGPoint(x: size.width / 2, y: size.height / 2)

        // Start pointer gesture
        handShadow.startPointing(at: point)

        // Create image from shadow
        if let image = renderShadowToImage(handShadow, size: size) {
            // Save image to file
            let filename = "\(outputDir)pointer_\(handType.stringValue).png"
            saveImage(image, to: filename)
            print("Saved pointer shadow image for \(handType.stringValue) hand to \(filename)")
        }

        // End pointer gesture to clean up
        handShadow.endPointing()
    }

    private func generateTwoFingerPanShadow(for handType: HandType, size: CGSize, outputDir: String) {
        let handShadow = HandShadow(for: handType)

        // Set up two points with reasonable distance between them
        let point1 = CGPoint(x: size.width / 2 - 60, y: size.height / 2)
        let point2 = CGPoint(x: size.width / 2 + 60, y: size.height / 2)

        // Start two-finger pan gesture
        handShadow.startTwoFingerPan(with: point1, and: point2)

        // Create image from shadow
        if let image = renderShadowToImage(handShadow, size: size) {
            // Save image to file
            let filename = "\(outputDir)pan_\(handType.stringValue).png"
            saveImage(image, to: filename)
            print("Saved two-finger pan shadow image for \(handType.stringValue) hand to \(filename)")
        }

        // End pan gesture to clean up
        handShadow.endTwoFingerPan()
    }

    private func generatePinchShadow(for handType: HandType, size: CGSize, outputDir: String) {
        let handShadow = HandShadow(for: handType)

        // Set up two points with reasonable distance for pinch
        let point1 = CGPoint(x: size.width / 2 - 80, y: size.height / 2 + 50)
        let point2 = CGPoint(x: size.width / 2 + 80, y: size.height / 2 - 50)

        // Start pinch gesture
        handShadow.startPinch(with: point1, and: point2)

        // Create image from shadow
        if let image = renderShadowToImage(handShadow, size: size) {
            // Save image to file
            let filename = "\(outputDir)pinch_\(handType.stringValue).png"
            saveImage(image, to: filename)
            print("Saved pinch shadow image for \(handType.stringValue) hand to \(filename)")
        }

        // End pinch gesture to clean up
        handShadow.endPinch()
    }

    private func renderShadowToImage(_ handShadow: HandShadow, size: CGSize) -> UIImage? {
        // Create a new image context
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }

        // Get the current context
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.translateBy(x: 700, y: 700)
        // Set the background to clear
        context.clear(CGRect(origin: .zero, size: size))

        // Render the shadow layer to the context
        handShadow.layer.render(in: context)

        // Get the image from the context
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    private func saveImage(_ image: UIImage, to path: String) {
        if let pngData = image.pngData() {
            try? pngData.write(to: URL(fileURLWithPath: path))
        }
    }
}
