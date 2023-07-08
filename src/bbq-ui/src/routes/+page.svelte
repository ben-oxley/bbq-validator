<script>
	import { createAppTheme } from '@arwes/theme';

	let name = 'Svelte';
    let scores = [];
	const t = createAppTheme({
		settings: {
			hues: {
				primary: 200,
				secondary: 80
			},
			fontFamilies: {
				title: 'Copperplate, Copper, "Comic Sans"',
				body: 'Tahoma, Techno, Trebuchet'
			}
		}
	});

    import { onMount } from "svelte";

    onMount(async () => {
      fetch("https://v6tglkvttzdinscq4lcc3cjjae0kcgit.lambda-url.eu-west-1.on.aws/")
      .then(response => response.json())
      .then(data => {
            console.log(data);
            scores = Object.entries(data).sort(([,a],[,b]) => b.score_sum-a.score_sum);
      }).catch(error => {
        console.log(error);
        return [];
      });
    });
    </script>



<main>
	<h1>Leaderboard</h1>
	<hr />
    {#each scores as score}
    <p>
		{score[0]}: Total score {score[1].score_sum} Total BBQs {score[1].count}
	</p>
{/each}

</main>

<style>
    main{
        border: 1px solid rgba(19, 164, 236, 0.298);
        padding: 1rem 2rem;
        border-radius: 1rem;
        background: linear-gradient(to right bottom, rgb(9, 17, 22), rgb(17, 35, 44));
    }
	h1 {
		font-family: Copperplate, Copper, 'Comic Sans';
		font-weight: 600;
		font-size: 1.75rem;
		color: rgb(89, 157, 190);
		-webkit-text-fill-color: transparent;
		margin: 0rem 0rem 1rem;
		background: -webkit-linear-gradient(0deg, rgb(43, 172, 237), rgb(172, 237, 43));
        -webkit-background-clip: text;
		color: transparent;
	}
	hr {
		margin: 0rem 0rem 1rem;
		border: none;
		height: 2px;
		background: linear-gradient(90deg, rgba(19, 164, 236, 0.298), rgba(166, 242, 13, 0.55));
	}
	p {
		margin: 0rem 0rem 1rem;
		font-family: Tahoma, Techno, Trebuchet;
		font-weight: 400;
		font-size: 1rem;
		color: rgb(89, 157, 190);
	}
	img {
		margin: 0px;
		max-width: 100%;
		border-radius: 0.5rem;
	}
</style>
