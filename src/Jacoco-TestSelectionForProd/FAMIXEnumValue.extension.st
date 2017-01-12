Extension { #name : #FAMIXEnumValue }

{ #category : #'*Jacoco-TestSelectionForProd' }
FAMIXEnumValue >> retrieveTests [
	^ self parentEnum retrieveTests
]
