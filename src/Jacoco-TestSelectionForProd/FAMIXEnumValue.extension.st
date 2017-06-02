Extension { #name : #FAMIXEnumValue }

{ #category : #'*Jacoco-TestSelectionForProd' }
FAMIXEnumValue >> retrieveTests [
	^ self parentEnum ifNotNil: [ :e | e retrieveTests ]
]
