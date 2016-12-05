Extension { #name : #FAMIXType }

{ #category : #'*Jacoco-TestSelectionForProd' }
FAMIXType >> retrieveTests [
	^ (OrderedCollection with: self)
		addAll: (self methods , self attributes flatCollect: [ :e | e retrieveTests ]);
		yourself
]
