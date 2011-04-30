# Aaron Okano, Jason Wong, Meenal Tambe, Gowtham Vijayaragavan

.text

.globl makechange

makechange:
	# ECX will store the pointer to the number on hand
	# EAX will store the pointer to the denomination
	# EBX will store the current amount
	# EDX will store the pointer to the change array
	# ESI will store the number of denominations
	# EDI will store the "return value" of findchange
	# makechange( amt, *onhand, *denoms, ndenoms, *thechange)
	# =========>  EBX    ECX      EAX      ESI       EDX

	call setregs	  # Use subroutine to grab arguments.
	call findchange	  # Finds if the current permutation works.
	cmpl $0, %edi	  # EDI will be set to 0 if the value is found.
	jz done

	# Skip up until call2 if the count of the current
	# on-hand denomination is 0.
	cmpl $0, (%ecx)
	jz call2
	# Prepare for next call.
	call reset_change
	# Backup c(ECX) before the next call.
	pushl (%ecx)
	# Now, decrement c(ECX) to be used in next call.
	decl (%ecx)
	# Push arguments.
	pushl %edx
	pushl %esi
	pushl %eax
	pushl %ecx
	pushl %ebx
	# RECURSION TIME!
	call makechange
	# Return the stack to the proper places.
	popl %ebx
	popl %ecx
	popl %eax
	popl %esi
	popl %edx
	# Pop c(ECX) back off.
	popl (%ecx)
	
	# Make sure the amount hasn't been found
call2:	cmpl $0, %edi
	jz done


	# Start preparing for second call
	cmpl $1, %esi
	jz done
	addl $4, %ecx
	decl %esi
	pushl %edx
	pushl %esi
	pushl %eax
	pushl %ecx
	pushl %ebx
	# RECURSION TIME!
	call makechange
	addl $20, %esp	  # Clean the stack

	# Check if amount was found
	cmpl $0, %edi
	jz done
	movl %edi, (%edx)
done:	ret

setregs:
	movl 8(%esp), %ebx
	movl 12(%esp), %ecx
	movl 16(%esp), %eax
	movl 20(%esp), %esi
	movl 24(%esp), %edx
	movl $-1, %edi
	ret


reset_change:
	# This function sets the change array to zeros.
	pushl %edx 	  # First, back up the data so it
	pushl %ecx	  # can be used for other things.
	pushl %esi
	movl $1, %ecx	  # Set up ECX as a counter.
	# Need to use the initial value of ESI for this
	movl -44(%ebp), %esi
loop:	movl $0, (%edx)	  # Simple loop to zero out thechange.
	cmpl %ecx, %esi
	jz finish
	addl $4, %edx
	incl %ecx
	jmp loop
finish:	# Restore data to original locations.
	popl %esi
	popl %ecx
	popl %edx
	ret

# FROM THIS POINT ON, ALL THE CODE DOES IS FIND THE DISTRIBUTION
# OF COINS FROM THE CURRENT PERMUTATION
findchange:
	# This function calculates the amount of change
	# from the given set of coins.

	# Back up previous contents.
	pushl %esi
	pushl %eax
	pushl %ebx
	pushl %ecx
	pushl %edx
	# We will need the pointer to the beginning of the on-hand array
	movl -52(%ebp), %ecx
	pushl (%ecx)	  # Stack temporarily holds on hand count.

top:	cmpl $0, %ebx	  # If the amount is zero,
	jz endsuccess	  # end the loop victoriously.
	cmpl (%eax), %ebx # If denomination > amount,
	jl lowdenom	  # use lower denomination.
	cmpl $0, (%ecx)   # If out of coins for this denomination,
	jz lowdenom	  # use lower denomination.
	subl (%eax), %ebx # Otherwise, subtract the denomination,
	decl (%ecx)	  # decrement the count,
	incl (%edx)	  # and increment the change count.
	jmp top
lowdenom:
	popl (%ecx)	  # Restore the on hand count.
	decl %esi
	cmpl $0, %esi	  # If there is no denomination at this level,
	jz endfail	  # end the loop and try again.
	addl $4, %eax	  # Move to next level of denomination.
	addl $4, %ecx
	addl $4, %edx
	pushl (%ecx)	  # Back up the new on hand count.
	jmp top
endsuccess:
	# Clear stack and return.
	addl $24, %esp
	movl $0, %edi
	ret
endfail:
	# Reset to original values.
	popl %edx
	popl %ecx
	popl %ebx
	popl %eax
	popl %esi
	ret
