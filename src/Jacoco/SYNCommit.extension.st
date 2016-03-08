Extension { #name : #SYNCommit }

{ #category : #'*Jacoco' }
SYNCommit >> hasAMethodCoveredByJacoco: toReject [

	^ self changes
		anySatisfy:
			[ :change | 
			(change modifiedEntities select: #isMethod)
				anySatisfy:
					[ :method | method isCoveredByJacocoTestMethodsByRejecting: toReject ] ]
]
