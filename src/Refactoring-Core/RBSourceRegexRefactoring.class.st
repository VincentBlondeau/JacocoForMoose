Class {
	#name : #RBSourceRegexRefactoring,
	#superclass : #RBRegexRefactoring,
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #private }
RBSourceRegexRefactoring >> parseMethod: aString [
	^ [ RBParser parseMethod: aString ]
		on: Error do: [ :err | nil ]
]

{ #category : #transforming }
RBSourceRegexRefactoring >> transform [
	| original replacement protocols |
	self model allClassesDo: [ :class |
		class selectors do: [ :selector |
			original := class sourceCodeFor: selector.
			replacement := self execute: original.
			replacement = original ifFalse: [
				(self parseMethod: replacement) isNil ifFalse: [
					protocols := class protocolsFor: selector.
					(class compiler parseSelector: replacement) = selector
						ifFalse: [ class removeMethod: selector ].
					class compile: replacement classified: protocols ] ] ] ]
]
