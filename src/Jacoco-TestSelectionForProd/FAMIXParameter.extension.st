Extension { #name : #FAMIXParameter }

{ #category : #'*Jacoco-TestSelectionForProd' }
FAMIXParameter >> retrieveTests [
	^ self parentBehaviouralEntity ifNotNil: [ :e | e retrieveTests ] ifNil: [ #() ]
]
