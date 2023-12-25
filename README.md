# AsyncImageTestApp

List of async images done for UIKit and SwiftUI.

Caching mechanism with 4 hours long storage implemented.
```
*** DownloadService.swift ***
private func fetchImage(descriptor: ImageDescriptor) -> AnyPublisher<UIImage?, Error> {
        guard let url = descriptor.url else {
            // return Just(descriptor.placeholder).tryMap { $0 }.eraseToAnyPublisher()
            return Just(nil).tryMap { $0 }.eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(handleResponse)
            .mapError { $0 }
            .handleEvents(receiveOutput: { [weak self] in
                guard let image: UIImage = ($0 ?? descriptor.placeholder) else {
                    return
                }
                self?.cacheService.store(ImageWrapper(image: image), for: descriptor.url?.absoluteString, expirationInSeconds: 14400)
            })
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
```
Isolated library works on simulator only. My aggregated script failed for making lib works both on devices and on simulators, so i left it only as simulator valid.
