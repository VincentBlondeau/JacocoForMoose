Extension { #name : #FAMIXBehaviouralEntity }

{ #category : #'*Jacoco-Import - static' }
FAMIXBehaviouralEntity >> duplicatedEntities [
	^ (self mooseModel allModelClassesAndInterfacesWithDuplicatedMethods
		includes: self belongsTo)
		ifTrue:
			[ self belongsTo methods
				select: [ :m | m signature = self signature ] ]
		ifFalse: [ {self} ]
]

{ #category : #'*Jacoco-Import' }
FAMIXBehaviouralEntity >> numberOfArgsFromSignature [
	<MSEProperty: #numberOfArgsFromSignature type: #Number>
	<MSEComment: 'numberOfArgsFromSignature'>
	
	| cut args |
	cut := self signature substrings: '('.
	args := cut second allButLast substrings: ','.
	"Just  good to have the number of args. 
	Ex :  'createPersistenceXml(Map<String,String>)'
	"
	
	^ args size - (cut second occurrencesOf: $<)
]
