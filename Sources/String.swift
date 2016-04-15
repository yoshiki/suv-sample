extension String {
    internal var bytes: [Int8] {
        return self.utf8.map{ Int8(bitPattern: $0) }
    }
}