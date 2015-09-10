Extension { #name : #FAMIXBehaviouralEntity }

{ #category : #'*Infinitest' }
FAMIXBehaviouralEntity >> staticlyFoundInfinitestTestMethodsCallingMyself [
	^ (self belongsTo coveredByInfinitestTests collect: [ :e | e testMethods ]) flatten
]
