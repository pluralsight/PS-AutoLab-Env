#this is a development function to test features. It is not normally exported
Function Test-It {
    [cmdletbinding()]
    Param(
        [int]$Minutes = 1
    )

    _SleepProgress -Minutes $Minutes
}