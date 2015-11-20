Class {
	#name : #JacocoMultiprojectStats,
	#superclass : #JacocoStats,
	#category : #'Jacoco-TestSelection'
}

{ #category : #'as yet unclassified' }
JacocoMultiprojectStats >> isMethodAnchorInTheCoreDir: method [
	^ method sourceAnchor
		ifNil: [ method belongsTo sourceAnchor fileName includesSubstring: 'src/main' ]
		ifNotNil: [ :sa | sa fileName includesSubstring: 'src/main' ]
]

{ #category : #'as yet unclassified' }
JacocoMultiprojectStats >> isMethodAnchorInTheTestDir: method [
	^ method sourceAnchor
		ifNil: [ method belongsTo sourceAnchor fileName includesSubstring: 'src/test' ]
		ifNotNil: [ :sa | sa fileName includesSubstring: 'src/test' ]
]
