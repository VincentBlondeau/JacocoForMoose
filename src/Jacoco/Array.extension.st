Extension { #name : #Array }

{ #category : #'*Jacoco' }
Array >> atTypeScope [
	^ self ifEmpty: [self ] ifNotEmpty: [self halt]
]
