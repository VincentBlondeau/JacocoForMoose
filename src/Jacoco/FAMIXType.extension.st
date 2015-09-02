Extension { #name : #FAMIXType }

{ #category : #'*Jacoco-Import temp to migrate to moose' }
FAMIXType >> methodsUnderstanding: signature [
	"returns true if a class is able to respond to an invocation to aSignature on itself; false otherwise"

	| return |
	return := OrderedCollection new.
	self
		withSuperclassesDo: [ :each | return add: (each implementationOf: signature) ].
	^ return select: #isNotNil
]
