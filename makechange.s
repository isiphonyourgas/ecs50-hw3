# Aaron Okano, Jason Wong, Meenal Tambe, Gowtham Vijayaragavan

.text

.globl makechange

makechange:
	# ECX will store the pointer to the number on hand
	# EAX will store the pointer to the denomination
	# EBX will store the current amount
	# EDX will store the pointer to the change array
	# ESI will store the number of denominations
	# EDI will do something that I have yet to settle on
	# makechange( amt, *onhand, *denoms, ndenoms, *thechange)
	# =========>  EBX    ECX      EAX      ESI       EDX

	call setregs	  # Use subroutine to grab arguments
	call findchange
	cmpl $0, %eax
	jz done

	# Prepare for next call
	# Use checknum subroutine to decrement ECX values to new permutation
	call checknum
	call reset_change
	# Push arguments
	pushl %edx
	pushl %esi
	pushl %eax
	pushl %ecx
	pushl %ebx
	# RECURSION TIME!
	call makechange
	addl $20, %esp 	  # Clean the stack
done:	ret

setregs:
	movl 8(%esp), %ebx
	movl 12(%esp), %ecx
	movl 16(%esp), %eax
	movl 20(%esp), %esi
	movl 24(%esp), %edx
	movl $-1, %edi
	ret

checknum:
	# This function will decrement the on-hand coin count
	cmpl $0, %ecx
	jz decrease
	decl (%ecx)
	ret
decrease:
	addl $4, %ecx
	addl $4, %eax
	movl $0, (%edx) # Clear the change value for this denomination
	addl $4, %edx
	decl %esi
	ret

reset_change:
	# This function sets the change array to zeros.
	pushl %edx 	  # First, back up the data so it
	pushl %ecx	  # can be used for other things.
	movl $1, %ecx	  # Set up ECX as a counter.
loop:	movl $0, (%edx)	  # Simple loop to zero out thechange.
	cmpl %ecx, %esi
	jz finish
	addl $4, %edx
	incl %ecx
	jmp loop
finish:	# Restore data to original locations.
	popl %ecx
	popl %edx
	ret

findchange:
	# This function calculates the amount of change
	# from the given set of coins.

	# Back up previous contents.
	pushl %esi
	pushl %eax
	pushl %ebx
	pushl %ecx
	pushl %edx
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
	movl $0, %eax
	ret
endfail:
	# Reset to original values.
	popl %edx
	popl %ecx
	popl %ebx
	popl %eax
	popl %esi
	ret
