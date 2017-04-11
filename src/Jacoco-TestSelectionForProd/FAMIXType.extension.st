Extension { #name : #FAMIXType }

{ #category : #'*Jacoco-TestSelectionForProd' }
FAMIXType >> allTestMethods [
	^ self methods select: #isJUnit4Test
]

{ #category : #'*Jacoco-TestSelectionForProd' }
FAMIXType >> retrieveTests [
	^ (OrderedCollection with: self)
		addAll: self methods;
		addAll: (self attributes flatCollect: [ :e | e retrieveTests ]) ;
		yourself
]
