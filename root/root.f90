! linear convergence
SUBROUTINE bisection( f, lBracket, rBracket, root )
    IMPLICIT NONE
    REAL                :: f
    REAL, INTENT(IN)    :: lBracket, rBracket
    REAL, INTENT(OUT)   :: root
    INTEGER             :: numIte, info
    REAL                :: left, right, error

    IF ( f(lBracket)*f(rBracket) > 0 ) THEN
        PRINT '(A)', "ROOT IS NOT BRACKETED"
        RETURN
    ELSE IF ( lBracket > rBracket ) THEN
        PRINT '(A)', "WRONG BRACKET ORDER"
        RETURN
    END IF

    left = lBracket
    right = rBracket

    numIte = 0
    DO
        root = 0.5 * ( left + right )
        error = 0.5 * (left - right )
        numIte = numIte + 1
        CALL printOutput( root, ABS(error), numIte, info )
        IF ( info == 1 .OR. info == 2 ) EXIT
        IF ( f(root)*f(left) < 0.0 ) THEN
            right = root
        ELSE
            left = root
        END IF
    END DO
END SUBROUTINE bisection

! quadratic convergence
SUBROUTINE newton_raphson( f, df, guess, root )
    IMPLICIT NONE
    REAL              :: f, df
    REAL, INTENT(IN)  :: guess
    REAL, INTENT(OUT) :: root
    INTEGER           :: numIte, info
    REAL              :: error

    numIte = 0
    root = guess
    DO
        error = -f(root)/df(root)
        root = root + error
        numIte = numIte + 1
        CALL printOutput( root, ABS(error), numIte, info )
        IF ( info == 1 .OR. info == 2 ) EXIT
    END DO
END SUBROUTINE newton_raphson

! superlinear convergence
! newton_raphson with approximated derivative
SUBROUTINE secant( f, fGuess, sGuess, root )
    IMPLICIT NONE
    REAL              :: f
    REAL, INTENT(IN)  :: fGuess, sGuess
    REAL, INTENT(OUT) :: root
    INTEGER           :: numIte, info
    REAL              :: error, x0, x1

    x0 = fGuess
    x1 = sGuess
    root = x1

    numIte = 0
    DO
        error = -f(x1) * (x1 - x0) / (f(x1) - f(x0))
        root = x1 + error
        numIte = numIte + 1
        CALL printOutput( root, ABS(error), numIte, info )
        IF ( info == 1 .OR. info == 2 ) EXIT
        x0 = x1
        x1 = root
    END DO
END SUBROUTINE secant

! combination of bisection and secant
SUBROUTINE falsePosition( f, lBracket, rBracket, root )
    IMPLICIT NONE
    REAL              :: f
    REAL, INTENT(IN)  :: lBracket, rBracket
    REAL, INTENT(OUT) :: root
    INTEGER           :: numIte, info
    REAL              :: previous_root, error, left, right

    IF ( f(lBracket)*f(rBracket) > 0 ) THEN
        WRITE (6,'(A)') "ROOT IS NOT BRACKETED"
        RETURN
    ELSE IF ( lBracket > rBracket ) THEN
        WRITE (6,'(A)') "WRONG BRACKET ORDER"
        RETURN
    END IF

    left = lBracket
    right = rBracket
    previous_root = 0.5 * (left + right)

    numIte = 0
    DO
        root = ( left*f(right) - right*f(left) ) / ( f(right) - f(left) )
        error = root - previous_root
        numIte = numIte + 1
        CALL printOutput( root, ABS(error), numIte, info )
        IF ( info == 1 .OR. info == 2 ) EXIT
        IF ( f(root)*f(left) < 0.0 ) THEN
            right = root
        ELSE
            left = root
        END IF
        previous_root = root
    END DO
END SUBROUTINE falsePosition

SUBROUTINE mueller( f, fGuess, sGuess, tGuess, root )
    IMPLICIT NONE
    REAL              :: f
    REAL, INTENT(IN)  :: fGuess, sGuess, tGuess
    REAL, INTENT(OUT) :: root
    INTEGER           :: numIte, info
    REAL              :: error, x0, x1, x2
    REAL              :: a, b, c, delta

    x0 = fGuess
    x1 = sGuess
    x2 = tGuess

    root = x2
    numIte = 0
    DO
        a = ( (f(x0) - f(x2))*(x1 - x2) - (f(x1) - f(x2))*(x0 - x2) ) / &
              ( (x0 - x2)*(x1 - x2)*(x0 - x1) )
        b = ( (f(x1) - f(x2))*(x0 - x2)**2 - (f(x0) - f(x2))*(x1 - x2)**2 ) / &
              ( (x0 - x2)*(x1 - x2)*(x0 - x1) )
        c = f(x2)
        delta = b**2 - 4*a*c
        IF ( b  >= 0 ) error = -2*c / (b + SQRT(delta))
        IF ( b < 0 ) error = -2*c / (b - SQRT(delta))
        root = root + error
        numIte = numIte + 1
        CALL printOutput( root, ABS(error), numIte, info )
        IF ( info == 1 .OR. info == 2 ) EXIT
        x0 = x1
        x1 = x2
        x2 = root
    END DO
END SUBROUTINE mueller

SUBROUTINE hybrid_newton_bisect( f, df, lBracket, rBracket, root )
    IMPLICIT NONE
    REAL                :: f, df
    REAL,INTENT(IN)     :: lBracket, rBracket
    REAL, INTENT(OUT)   :: root
    INTEGER             :: numIte, info
    REAL                :: left, right, error

    IF ( f(lBracket)*f(rBracket) > 0 ) THEN
        WRITE (6,'(A)') "ROOT IS NOT BRACKETED"
        RETURN
    ELSE IF ( lBracket > rBracket ) THEN
        WRITE (6,'(A)') "WRONG BRACKET ORDER"
        RETURN
    END IF

    left = lBracket
    right = rBracket

    root = 0.5 * (left + right)
    numIte = 0

    DO
        error = - f(root)/df(root)
        root = root + error
        numIte = numIte + 1
        CALL printOutput( root, ABS(error), numIte, info )
        IF ( root >= left .AND. root <= right ) THEN
            IF ( info == 1 .OR. info == 2 ) EXIT
        ELSE
            root = 0.5 * ( left + right )
            error = 0.5 * (left - right )
            numIte = numIte + 1
            CALL printOutput( root, ABS(error), numIte, info )
            IF ( info == 1 .OR. info == 2 ) EXIT
            IF ( f(root)*f(left) < 0.0 ) THEN
                right = root
            ELSE
                left = root
            END IF
        END IF
    END DO
END SUBROUTINE hybrid_newton_bisect
