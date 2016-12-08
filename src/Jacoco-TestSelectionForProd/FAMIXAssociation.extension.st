Extension { #name : #FAMIXAssociation }

{ #category : #'*Jacoco-TestSelectionForProd' }
FAMIXAssociation >> retrieveTests [
	^ self from ifNotNil: [ :var | var retrieveTests ] ifNil: [ #() ]
]
