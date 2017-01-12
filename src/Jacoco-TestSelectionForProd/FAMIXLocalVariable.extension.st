Extension { #name : #FAMIXLocalVariable }

{ #category : #'*Jacoco-TestSelectionForProd' }
FAMIXLocalVariable >> retrieveTests [
	^ self parentBehaviouralEntity ifNotNil: [ :e | e retrieveTests ] ifNil: [ #() ]
]
