using System.Collections;
using UnityEngine;

public class MainMenuManager : MonoBehaviour
{
    public GameObject menuCanvas;
    public GameObject blackScreen;
    public GameObject menuCamera;
    public GameObject player;

    [Header("Transition Settings")]
    public float transitionDuration = 2.0f; 

    void Start()
    {
        if (player != null) 
        {
            player.SetActive(false);
        }

        menuCanvas.SetActive(true);
        blackScreen.SetActive(false);
        menuCamera.SetActive(true);

        Cursor.visible = true;
        Cursor.lockState = CursorLockMode.None;
    }

    public void PlayGame()
    {
        StartCoroutine(StartGameRoutine());
    }

    private IEnumerator StartGameRoutine()
    {
        menuCanvas.SetActive(false);
        blackScreen.SetActive(true);

        
        yield return new WaitForSeconds(transitionDuration);

        blackScreen.SetActive(false);
        menuCamera.SetActive(false);

        if (player != null) 
        {
            player.SetActive(true);
        }

        Cursor.visible = false;
        Cursor.lockState = CursorLockMode.Locked;
    }
}