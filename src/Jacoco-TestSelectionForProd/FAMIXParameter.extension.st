Extension { #name : #FAMIXParameter }

{ #category : #'*Jacoco-TestSelectionForProd' }
FAMIXParameter >> retrieveTests [
	^ self parentBehaviouralEntity retrieveTests
]
