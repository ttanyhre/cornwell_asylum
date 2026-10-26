using System.Collections;
using UnityEngine;

public class MainMenuManager : MonoBehaviour
{
    public GameObject menuCanvas;
    public GameObject blackScreen;
    public GameObject menuCamera;
    public GameObject player;

    public void PlayGame()
    {
        StartCoroutine(StartGameRoutine());
    }

    private IEnumerator StartGameRoutine()
    {
        menuCanvas.SetActive(false);
        blackScreen.SetActive(true);

        yield return new WaitForSeconds(2.0f);

        blackScreen.SetActive(false);
        menuCamera.SetActive(false);
        player.SetActive(true);
    }
}